//
//  CartCell.swift
//  Pizza
//
//  Created by Alexander Kosse on 22/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {

    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var doughLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var layerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        minusButton.layer.cornerRadius = 4.0
        minusButton.layer.borderWidth = 1.0
        minusButton.layer.borderColor = UIColor.AlphaCoral().cgColor
        minusButton.layer.masksToBounds = true
        //minusButton.isSelected = true
        
        plusButton.layer.cornerRadius = 4.0
        plusButton.layer.borderWidth = 1.0
        plusButton.layer.borderColor = UIColor.AlphaCoral().cgColor
        plusButton.layer.masksToBounds = true
        //plusButton.isSelected = true

        layerView.layer.cornerRadius = 4.0
        layerView.layer.borderWidth = 1.0
        layerView.layer.borderColor = UIColor.clear.cgColor
        layerView.layer.masksToBounds = true
        
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowRadius = 2.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.masksToBounds = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func countStepperAction(_ sender: UIStepper) {
        countLabel.text = String(sender.value)
    }
}
