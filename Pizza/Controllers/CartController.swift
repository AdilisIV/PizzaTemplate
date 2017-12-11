//
//  CartController.swift
//  Pizza
//
//  Created by Alexander Kosse on 21/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class CartController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var orderTotalLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var summaryView: UIView!

    private var notificationToken: NotificationToken?
    
    private let purchases = try! Realm().objects(PurchaseObject.self).sorted(byKeyPath: "date", ascending: true)
    private let sizes = try! Realm().objects(SizeObject.self)
    private let doughs = try! Realm().objects(DoughObject.self)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderButton.layer.backgroundColor = UIColor.DarkCoral().cgColor
        orderButton.layer.cornerRadius = 4.0
        orderButton.layer.masksToBounds = true
        
        tableView.rowHeight = 158 //UITableViewAutomaticDimension;
        tableView.estimatedRowHeight = 158
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 3))
        header.backgroundColor = .clear
        tableView.tableHeaderView = header
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 1))
        footer.backgroundColor = .clear
        tableView.tableFooterView = footer
        
        let nb = navigationController!.navigationBar.layer
        nb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        nb.shadowOffset = CGSize(width: 0, height: 0)
        nb.shadowRadius = 3.0
        nb.shadowOpacity = 1.0
        nb.masksToBounds = false
        
        let sv = summaryView.layer
        sv.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        sv.shadowOffset = CGSize(width: 0, height: 0)
        sv.shadowRadius = 3.0
        sv.shadowOpacity = 1.0
        sv.masksToBounds = false
        
        self.notificationToken = purchases.observe { changes in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.tableView.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                if insertions == [] && deletions == [] {
                    self.tableView.beginUpdates()
                    self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .none)
                    self.tableView.endUpdates()
                } else {
                    UIView.animate(withDuration: 0.3, animations: {
                        self.tableView.beginUpdates()
                        self.tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.reloadRows(at: modifications.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) }, with: .automatic)
                        self.tableView.endUpdates()
                        //self.tableView.reloadData()
                    }, completion: { (finished) in
                        self.tableView.reloadData()
                    })
                }
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
            self.updateBadge()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let tb = tabBarController!.tabBar.layer
        tb.shadowColor = UIColor.clear.cgColor
        tb.shadowOffset = CGSize(width: 0, height: 0)
        tb.shadowRadius = 3.0
        tb.shadowOpacity = 1.0
        tb.masksToBounds = true
        tableView.reloadData()
    }
    
    @IBAction func decreaseAction(_ sender: UIButton) {
        let purchase = purchases[sender.tag]
        if purchase.productCount > 1 {
            try! Realm().write {
                purchase.productCount-=1
            }
        }
    }
    
    @IBAction func increaseAction(_ sender: UIButton) {
        let purchase = purchases[sender.tag]
        if purchase.productCount < 99 {
            try! Realm().write {
                purchase.productCount+=1
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        let purchase = purchases[sender.tag]
        let realm = try! Realm()
        try! realm.write {
            realm.delete(purchase)
        }
    }
    
    func updateBadge() {
        var badge = 0
        var total: Double = 0
        for purchase in purchases {
            if let product = try! Realm().objects(ProductObject.self).filter("id=\(purchase.productId)").first {
                let variant = product.variants[purchase.productVariant]
                total += variant.price * Double(purchase.productCount)
            }
            badge += purchase.productCount
        }
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.perMillSymbol = " "
        formatter.locale = Locale(identifier: "ru")
        
        let astring = NSMutableAttributedString(string: formatter.string(from: total as NSNumber)!)
        let size = orderTotalLabel.font.pointSize
        let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : orderTotalLabel.font.withSize(size*0.75)])
        astring.append(asuffix)
        orderTotalLabel.attributedText = astring

        if let items = tabBarController?.tabBar.items {
            if items.count > 3 {
                let item = items[3] as UITabBarItem
                item.badgeValue = (badge == 0) ? nil : "\(badge)"
            }
        }
    }
    
    /////////////////////////////////// Table View Delegate /////////////////////////////////////
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = purchases.count
        if count == 0 {
            if let emptyView = Bundle.main.loadNibNamed("EmptyCollectionView", owner: self, options: nil)?.first as? EmptyCollectionView {
                emptyView.textLabel.text = "Нет товаров в корзине"
                tableView.backgroundView = emptyView
            }
        } else {
            tableView.backgroundView = nil
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = .clear
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CartCell", for: indexPath) as! CartCell
        let index = indexPath.row
        cell.tag = index
        cell.cartButton.tag = index
        cell.minusButton.tag = index
        cell.plusButton.tag = index
        let purchase = purchases[index]
        if let product = try! Realm().objects(ProductObject.self).filter("id=\(purchase.productId)").first {
            if let url = URL(string: product.icons.first!) {
                DispatchQueue.main.async { cell.productImageView.kf.setImage(with: url, placeholder:UIImage(named:"ImagePlaceholder")) }
            } else {
                cell.productImageView.image = UIImage(named:"ImagePlaceholder")
            }
            let variant = product.variants[purchase.productVariant]

            cell.titleLabel.text = product.title
            cell.countLabel.text = String(describing: purchase.productCount)
            if let size = sizes.filter("id=\(variant.size)").first {
                cell.sizeLabel.text = "Размер: " + size.title
            } else { cell.sizeLabel.text = "" }
            if let dough = doughs.filter("id=\(variant.dough)").first {
                cell.doughLabel.text = "Тесто: " + dough.title
            } else { cell.doughLabel.text = "" }
            cell.descriptionLabel.text = product.fullDescription

            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.perMillSymbol = " "
            formatter.locale = Locale(identifier: "ru")

            let astring = NSMutableAttributedString(string: formatter.string(from: (variant.price * Double(purchase.productCount)) as NSNumber)!)
            let size = cell.priceLabel.font.pointSize
            let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : cell.priceLabel.font.withSize(size*0.75)])
            astring.append(asuffix)
            cell.priceLabel.attributedText = astring
        }
        return cell
    }
}
