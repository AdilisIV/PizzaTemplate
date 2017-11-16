//
//  CatalogCell.swift
//  Pizza
//
//  Created by Alexander Kosse on 14/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class CatalogCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        
        self.contentView.layer.cornerRadius = 2.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.clear.cgColor
        self.contentView.layer.masksToBounds = true
        
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.layer.shadowRadius = 2.0
        self.layer.shadowOpacity = 1.0
        self.layer.masksToBounds = false
    }
}
