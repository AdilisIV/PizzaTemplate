//
//  CartController.swift
//  Pizza
//
//  Created by Alexander Kosse on 21/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class CartController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderButton.layer.backgroundColor = UIColor.DarkCoral().cgColor
        orderButton.layer.cornerRadius = 4.0
        orderButton.layer.masksToBounds = true
    }
    
    /////////////////////////////////// Table View Delegate /////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        return cell
    }
}
