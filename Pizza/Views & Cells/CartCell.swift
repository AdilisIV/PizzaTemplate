//
//  CartCell.swift
//  Pizza
//
//  Created by Alexander Kosse on 22/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class CartCell: UITableViewCell {

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var bonusLabel: UILabel!
    @IBOutlet weak var doughSelector: UISegmentedControl!
    @IBOutlet weak var sizeSelector: UISegmentedControl!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    @IBAction func countStepperAction(_ sender: UIStepper) {
        countLabel.text = String(sender.value)
    }
}
