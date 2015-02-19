//
//  StickyHeaderFlowLayout.swift
//  
//
//  Created by Stefan Herold on 18.02.15.
//
//

import UIKit

class StickyHeaderFlowLayout: UICollectionViewFlowLayout {
	let StickyHeaderParallaxHeader = "StickyHeaderParallaxHeader"
	var parallaxHeaderReferenceSize = CGSizeZero
	var parallaxHeaderMinimumReferenceSize = CGSizeZero
	var parallaxHeaderAlwaysOnTop = false
	var disableStickyHeaders = false
	
	override func prepareLayout() {
		super.prepareLayout()
	}
	
	override func initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
		let attributes = super.initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind, atIndexPath: elementIndexPath)
		attributes?.frame.origin.y = self.parallaxHeaderReferenceSize.height
		return attributes
	}
	
	override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
		var attributes = super.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath)
		if attributes == nil && elementKind == StickyHeaderParallaxHeader {
			attributes = StickyHeaderFlowLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
		}
		return attributes
	}
	
	override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
		var adjustedRect = rect
		adjustedRect.origin.y -= self.parallaxHeaderReferenceSize.height
		
		var allItems = super.layoutAttributesForElementsInRect(adjustedRect) as! [UICollectionViewLayoutAttributes]
		var headers = [Int : UICollectionViewLayoutAttributes]()
		var lastCells = [Int : UICollectionViewLayoutAttributes]()
		var visibleParallaxHeader = false
		
		for obj in allItems {
			let attributes = obj as! StickyHeaderFlowLayoutAttributes
			let indexPath = attributes.indexPath
			
			attributes.frame.origin.y += parallaxHeaderReferenceSize.height
			
			if let representedElementKind = obj.representedElementKind where representedElementKind == UICollectionElementKindSectionHeader {
				headers[indexPath.section] = obj
			} else if let let representedElementKind = obj.representedElementKind where representedElementKind == UICollectionElementKindSectionFooter {
				// Not implemented
			} else {
				let currentAttribute = lastCells[indexPath.section]
				
				// Get the bottom most cell of that section
				if currentAttribute == nil || indexPath.row > currentAttribute?.indexPath.row {
					lastCells[indexPath.section] = obj
				}
				
				if indexPath.item == 0 && indexPath.section == 0 {
					visibleParallaxHeader = true
				}
			}
			
			// For iOS 7.0, the cell zIndex should be above sticky section header
			attributes.zIndex = 1
		}
		
		// when the visible rect is at top of the screen, make sure we see the parallax header
		if CGRectGetMinY(rect) <= 0 {
			visibleParallaxHeader = true
		}
		
		if self.parallaxHeaderAlwaysOnTop == true {
			visibleParallaxHeader = true
		}
		
		if let collectionView = self.collectionView  {
			// This method may not be explicitly defined, default to 1
			// https://developer.apple.com/library/ios/documentation/uikit/reference/UICollectionViewDataSource_protocol/Reference/Reference.html#jumpTo_6
			var numberOfSections = 1
			
			if let number = collectionView.dataSource?.numberOfSectionsInCollectionView?(collectionView) {
				numberOfSections = number
			}
			
			// Create the attributes for the Parallax header
			if visibleParallaxHeader && CGSizeEqualToSize(CGSizeZero, self.parallaxHeaderReferenceSize) == false {
				let currentAttribute = StickyHeaderFlowLayoutAttributes(forSupplementaryViewOfKind: StickyHeaderParallaxHeader, withIndexPath: NSIndexPath(index: 0))
				currentAttribute.frame.size.width = self.parallaxHeaderReferenceSize.width
				currentAttribute.frame.size.height = self.parallaxHeaderReferenceSize.height
				
				let bounds = collectionView.bounds
				let maxY = CGRectGetMaxY(currentAttribute.frame)
				
				// make sure the frame won't be negative values
				var y = min(maxY - self.parallaxHeaderMinimumReferenceSize.height, bounds.origin.y + collectionView.contentInset.top)
				let height = max(0, -y + maxY)
				
				let maxHeight = self.parallaxHeaderReferenceSize.height
				let minHeight = self.parallaxHeaderMinimumReferenceSize.height
				let progressiveness = Int((height - minHeight)/(maxHeight - minHeight))
				currentAttribute.progressiveness = progressiveness
				
				// if zIndex < 0 would prevents tap from recognized right under navigation bar
				currentAttribute.zIndex = 0;
				
				// When parallaxHeaderAlwaysOnTop is enabled, we will check when we should update the y position
				if self.parallaxHeaderAlwaysOnTop && height <= self.parallaxHeaderMinimumReferenceSize.height {
					let insetTop = collectionView.contentInset.top
					// Always stick to top but under the nav bar
					y = collectionView.contentOffset.y + insetTop;
					currentAttribute.zIndex = 2000;
				}
				
				currentAttribute.frame = CGRectMake(currentAttribute.frame.origin.x, y, currentAttribute.frame.size.width, height)
				allItems.append(currentAttribute)
			}
			
			if disableStickyHeaders == false {
				for (section, attributes) in lastCells {
					let indexPath = attributes.indexPath
					var header = headers[indexPath.section]
					// CollectionView automatically removes headers not in bounds
					
					if header == nil {
						header = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: indexPath.section))
						
						if header != nil {
							allItems.append(header!)
						}
					}
					self.updateHeaderAttributes(header, lastCellAttributes: lastCells[indexPath.section]!)
				}
			}
		}
		
		return allItems
	}
	
	override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
		let attributes = super.layoutAttributesForItemAtIndexPath(indexPath)
		attributes.frame.origin.y += self.parallaxHeaderReferenceSize.height
		return attributes
	}
	
	override func collectionViewContentSize() -> CGSize {
		var size = super.collectionViewContentSize()
		size.height += self.parallaxHeaderMinimumReferenceSize.height
		return size
	}
	
	override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
		if let bounds = self.collectionView?.bounds {
			if CGRectGetWidth(bounds) != CGRectGetWidth(newBounds) {
				return true
			}
		}
		return false
	}
	
	// MARK: Overrides
	
	override class func layoutAttributesClass() -> AnyClass {
		return StickyHeaderFlowLayoutAttributes.self
	}
	
	// MARK: Helper
	
	private func updateHeaderAttributes(attributes: UICollectionViewLayoutAttributes?, lastCellAttributes: UICollectionViewLayoutAttributes) {
		if let collectionView = self.collectionView, attributes = attributes {
			let currentBounds = collectionView.bounds
			attributes.zIndex = 1024
			attributes.hidden = false
			let origin = attributes.frame.origin
			let sectionMaxY = CGRectGetMaxY(lastCellAttributes.frame) - attributes.frame.size.height
			var y = CGRectGetMaxY(currentBounds) - currentBounds.size.height + collectionView.contentInset.top
			
			if self.parallaxHeaderAlwaysOnTop {
				y += self.parallaxHeaderMinimumReferenceSize.height
			}
			
			let maxY = min(max(y, attributes.frame.origin.y), sectionMaxY)
			
			attributes.frame.origin = CGPointMake(origin.x, maxY)
		}
	}
}
