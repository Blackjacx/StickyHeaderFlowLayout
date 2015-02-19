//
//  TitleCell.swift
//  Kundencenter
//
//  Created by Stefan Herold on 16.02.15.
//  Copyright (c) 2015 Deutsche Telekom AG. All rights reserved.
//

import UIKit

class TitleCell: UICollectionViewCell {

	@IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
		
		let selectedView = UIView()
		selectedView.backgroundColor = UIColor.lightGrayColor()
		self.selectedBackgroundView = selectedView
    }
}
