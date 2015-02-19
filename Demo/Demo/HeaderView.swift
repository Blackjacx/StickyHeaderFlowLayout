//
//  HeaderView.swift
//  Demo
//
//  Created by Stefan Herold on 19.02.15.
//  Copyright (c) 2015 Stefan Herold. All rights reserved.
//

import UIKit

class HeaderView: UICollectionReusableView {
	@IBOutlet weak var titleLabel: UILabel!
	
	override func awakeFromNib() {
		super.awakeFromNib()
		self.backgroundColor = UIColor.lightGrayColor()
	}
}
