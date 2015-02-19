//
//  InvoicesViewController.swift
//  Kundencenter
//
//  Created by Stefan Herold on 19.11.14.
//  Copyright (c) 2014 Deutsche Telekom AG. All rights reserved.
//

import UIKit


class CollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

	private let reuseIDTitleCell = "TitleCell"
	private let reuseIDHeaderView = "HeaderView"
	
	override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
		coordinator.animateAlongsideTransition({ (ctx) -> Void in
			self.collectionViewLayout.invalidateLayout()
			}, completion: nil)
	}
	
	// TODO: Deprecated - It is safe to delete this in iOS8++ apps. The above viewWillTransitionToSize will replace it.
	override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
		self.collectionViewLayout.invalidateLayout()
	}
	
	// MARK: UICollectionViewDataSource
	
	override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 5
	}
 
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return 10
	}
 
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIDTitleCell, forIndexPath: indexPath) as! TitleCell
		cell.titleLabel.text = "(\(indexPath.section), \(indexPath.item))"
		return cell
	}
	
	override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
		var header: HeaderView?
		
		if kind == UICollectionElementKindSectionHeader {
			header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIDHeaderView, forIndexPath: indexPath) as? HeaderView
			header?.backgroundColor = UIColor.lightGrayColor()
		}
		header?.titleLabel.text = NSLocalizedString("This is the Funny Header 🎉", comment:"")
		return header!
	}
	
	// MARK: UICollectionViewDelegateFlowLayout
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
		if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
			return CGSizeMake(8*12, 8*12)
		} else {
			return CGSizeMake(self.view.frame.size.width, 4*12)
		}
	}
}
