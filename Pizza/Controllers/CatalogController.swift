//
//  CatalogController.swift
//  Pizza
//
//  Created by Alexander Kosse on 14/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON

class CityObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    override static func primaryKey() -> String? { return "id" }
}

class CategoryObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    @objc dynamic var icon = String()
    let products = List<ProductObject>()
    override static func primaryKey() -> String? { return "id" }
}

class VariantObject: Object {
    @objc dynamic var weight = Double()
    @objc dynamic var price = Double()
    @objc dynamic var size = Int()
    @objc dynamic var dough = Int()
}

class SizeObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    override static func primaryKey() -> String? { return "id" }
}

class DoughObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    override static func primaryKey() -> String? { return "id" }
}

class ProductObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var category = Int()
    @objc dynamic var title = String()
    @objc dynamic var fullDescription = String()
    @objc dynamic var icon = String()
    @objc dynamic var units = String()
    @objc dynamic var favorite = false
    let variants = List<VariantObject>()
    override static func primaryKey() -> String? { return "id" }
}

class CartItemObject: Object {
    var productId = Int()
    var productSize = Int()
    var productType = Int()
    var productCount = Int()
}

class CatalogController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {

    private var refreshControl = UIRefreshControl()
    private var searchController = UISearchController()
    private var condencedLayout = false
    
    private var notificationToken: NotificationToken?
    var currentCategory = 0
    
    private let purchases = try! Realm().objects(CartItemObject.self)
    private let categories = try! Realm().objects(CategoryObject.self)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if #available(iOS 11.0, *) {
            collectionView?.insetsLayoutMarginsFromSafeArea = true
            //navigationItem.searchController = searchController
        }
        refreshControl.addTarget(self, action: #selector(CatalogController.refreshAction), for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            collectionView?.refreshControl = refreshControl
        } else {
            collectionView?.addSubview(refreshControl)
        }
        let nb = navigationController!.navigationBar.layer
        nb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        nb.shadowOffset = CGSize(width: 0, height: 0)
        nb.shadowRadius = 3.0
        nb.shadowOpacity = 1.0
        nb.masksToBounds = false
        let tb = tabBarController!.tabBar.layer
        tb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        tb.shadowOffset = CGSize(width: 0, height: 0)
        tb.shadowRadius = 3.0
        tb.shadowOpacity = 1.0
        tb.masksToBounds = false

        updateCatalog()

        self.notificationToken = categories[currentCategory].products.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.collectionView?.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }, completion: { (completed) in })
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }

//    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let color = UIColor.DarkCoral()
//        guard let verticalIndicator = scrollView.subviews.last as? UIImageView,
//            verticalIndicator.backgroundColor != color,
//            verticalIndicator.image?.renderingMode != .alwaysTemplate
//            else { return }
//        verticalIndicator.layer.masksToBounds = true
//        verticalIndicator.layer.cornerRadius = verticalIndicator.frame.width / 2
//        verticalIndicator.backgroundColor = color
//        verticalIndicator.image = verticalIndicator.image?.withRenderingMode(.alwaysTemplate)
//        verticalIndicator.tintColor = .clear
//    }
    
    @objc func refreshAction() {
        refreshControl.endRefreshing()
    }
    
    func updateCatalog() {
        if let path = Bundle.main.path(forResource: "pizza", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let json = try JSON(data: data)
                let realm = try! Realm()
                try! realm.write {
                    for i in json["products"].arrayValue {
                        let c = ProductObject()
                        c.id = i["id"].intValue
                        c.category = i["category"].intValue
                        c.title = i["title"].stringValue
                        c.fullDescription = i["description"].stringValue
                        c.icon = i["icon"].stringValue
                        c.units = i["units"].stringValue
                        for j in i["variants"].arrayValue {
                            let v = VariantObject()
                            v.weight = j["weight"].doubleValue
                            v.price = j["price"].doubleValue
                            v.size = j["size"].intValue
                            v.dough = j["dough"].intValue
                            c.variants.append(v)
                        }
                        realm.add(c, update: true)
                    }
                }
                try! realm.write {
                    for i in json["categories"].arrayValue {
                        let c = CategoryObject()
                        c.id = i["id"].intValue
                        c.title = i["title"].stringValue
                        c.icon = i["icon"].stringValue
                        c.products.append(objectsIn: realm.objects(ProductObject.self).filter("category=\(c.id)"))
                        realm.add(c, update: true)
                    }
                    for i in json["sizes"].arrayValue {
                        let c = SizeObject()
                        c.id = i["id"].intValue
                        c.title = i["title"].stringValue
                        realm.add(c, update: true)
                    }
                    for i in json["doughs"].arrayValue {
                        let c = DoughObject()
                        c.id = i["id"].intValue
                        c.title = i["title"].stringValue
                        realm.add(c, update: true)
                    }
                }
                //print(json)
            } catch {
                print("pizza.json not valid")
            }
        }
    }
    
    func updateLayout(size: CGSize, animated: Bool) {
        
        let currentlayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = collectionView!.safeAreaInsets
        }
        
        let columns = (size.width > size.height) ? 4 : 2 as CGFloat
        var width = (size.width-10-insets.left-insets.right-(columns-1)*2)/columns
        var height = width + 120
        if condencedLayout {
            width = size.width-insets.left-insets.right-8
            height = 100
        }
        let cellSize = CGSize(width: width, height: height)
        if currentlayout.itemSize == cellSize { return }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 2
        if #available(iOS 11.0, *) {
            layout.sectionInsetReference = .fromSafeArea
        }
        collectionView?.setCollectionViewLayout(layout, animated: animated)
    }

    @IBAction func favoriteAction(_ sender: UIButton) {
        let index = sender.superview!.superview!.superview!.tag
        let product = categories[currentCategory].products[index]
        let realm = try! Realm()
        try! realm.write {
            product.favorite = !product.favorite
        }
    }
    
    @IBAction func changeLayout(_ sender: UIButton) {
        condencedLayout = !condencedLayout
        if condencedLayout {
            sender.setImage(UIImage(named: "NormalCollection"), for: .normal)

        } else {
            sender.setImage(UIImage(named: "CompactCollection"), for: .normal)
        }
        updateLayout(size: collectionView!.bounds.size, animated: false)
        collectionView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowCategorySegue" {
            let categoryController = segue.destination as! CategoryController
            categoryController.catalogController = self
            categoryController.currentCategory = currentCategory
        }
    }
    
    ///////////////////////////// Collection View Delegate ///////////////////////////////
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if layoutChangeInProgress { return 0}
        return categories[currentCategory].products.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let product = categories[currentCategory].products[index]
        if condencedLayout {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CondencedCell", for: indexPath) as! CondencedCell
            cell.tag = index
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.fullDescription
            cell.favoriteButton.isSelected = product.favorite
            if let url = URL(string: product.icon) {
                DispatchQueue.main.async { cell.imageView.kf.setImage(with: url) }
            } else {
                cell.imageView.image = UIImage(named:"ImagePlaceholder")
            }
            if let variant = product.variants.first {
                let astring = NSMutableAttributedString(string: "\(variant.price)")
                let size = cell.priceLabel.font.pointSize
                let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : cell.priceLabel.font.withSize(size*0.75)])
                astring.append(asuffix)
                cell.priceLabel.attributedText = astring
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
            cell.tag = index
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.fullDescription
            cell.favoriteButton.isSelected = product.favorite
            if let url = URL(string: product.icon) {
                DispatchQueue.main.async { cell.imageView.kf.setImage(with: url) }
            } else {
                cell.imageView.image = UIImage(named:"ImagePlaceholder")
            }
            if let variant = product.variants.first {
                let astring = NSMutableAttributedString(string: "\(variant.price)")
                let size = cell.priceLabel.font.pointSize
                let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : cell.priceLabel.font.withSize(size*0.75)])
                astring.append(asuffix)
                cell.priceLabel.attributedText = astring
            }
            return cell
        }
    }
    
    ///////////////////////////// Search Results Delegate ///////////////////////////
    
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        //searchActive = false
    }
}
