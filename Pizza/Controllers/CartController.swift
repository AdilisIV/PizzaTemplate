//
//  CartController.swift
//  Pizza
//
//  Created by Alexander Kosse on 21/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class CartController: UIViewController {

    @IBOutlet weak var orderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderButton.layer.backgroundColor = UIColor.DarkCoral().cgColor
        orderButton.layer.cornerRadius = 4.0
//        orderButton.layer.borderWidth = 1.0
//        orderButton.layer.borderColor = UIColor.DarkCoral().cgColor
        orderButton.layer.masksToBounds = true
    }
}
