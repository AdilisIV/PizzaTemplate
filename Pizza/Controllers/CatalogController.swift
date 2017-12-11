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

class IngredientObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var title = String()
    @objc dynamic var weight = Double()
    @objc dynamic var price = Double()
    @objc dynamic var icon = String()
    override static func primaryKey() -> String? { return "id" }
}

class AddedIngredientObject: Object {
    @objc dynamic var ingredientId = Int()
    @objc dynamic var ingredientCount = Int()
}

class ProductObject: Object {
    @objc dynamic var id = Int()
    @objc dynamic var category = Int()
    @objc dynamic var title = String()
    @objc dynamic var fullDescription = String()
    @objc dynamic var units = String()
    @objc dynamic var favorite = Bool()
    let icons = List<String>()
    let variants = List<VariantObject>()
    let ingredients = List<IngredientObject>()
    override static func primaryKey() -> String? { return "id" }
}

class PurchaseObject: Object {
    @objc dynamic var productId = Int()
    @objc dynamic var productVariant = Int()
    @objc dynamic var productCount = Int()
    @objc dynamic var date = Date()
    let addedIngredients = List<AddedIngredientObject>()
}

class CatalogController: UICollectionViewController, UISearchResultsUpdating, UISearchBarDelegate {

    @IBOutlet weak var categoryButton: UIBarButtonItem!
    
    private var refreshControl = UIRefreshControl()
    private var searchController = UISearchController()
    private var condencedLayout = false
    private var notificationToken: NotificationToken?
    
    var currentProduct = 0
    private var privateCategory = 0
    var currentCategory: Int {
        get { return privateCategory }
        set(newCategory) {
            privateCategory = newCategory
            addCategoryObserver()
        }
    }
    
    var cartBadge = 0
    
    private let purchases = try! Realm().objects(PurchaseObject.self).sorted(byKeyPath: "date", ascending: true)
    private let categories = try! Realm().objects(CategoryObject.self).sorted(byKeyPath: "id", ascending: true)

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
        
//        let tb = tabBarController!.tabBar.layer
//        tb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
//        tb.shadowOffset = CGSize(width: 0, height: 0)
//        tb.shadowRadius = 3.0
//        tb.shadowOpacity = 1.0
//        tb.masksToBounds = false

        updateCatalog()
        currentCategory = 0
        categoryButton.title = "▼ " + categories[currentCategory].title
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout(size: collectionView!.bounds.size, animated: false)
        let tb = tabBarController!.tabBar.layer
        tb.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).cgColor
        tb.shadowOffset = CGSize(width: 0, height: 0)
        tb.shadowRadius = 3.0
        tb.shadowOpacity = 1.0
        tb.masksToBounds = false
    }
    
    override func viewSafeAreaInsetsDidChange() {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }
    
    func addCategoryObserver() {
        if currentCategory >= categories.count { return }
        self.notificationToken = categories[currentCategory].products.observe { (changes: RealmCollectionChange) in
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                self.collectionView?.reloadData()
                break
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the TableView
                //self.collectionView?.reloadData()
                self.collectionView?.performBatchUpdates({
                    self.collectionView?.insertItems(at: insertions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.deleteItems(at: deletions.map { IndexPath(row: $0, section: 0) })
                    self.collectionView?.reloadItems(at: modifications.map { IndexPath(row: $0, section: 0) })
                }, completion: { (completed) in /*self.collectionView?.reloadData()*/ })
                break
            case .error(let err):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(err)")
                break
            }
        }
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
        updateCatalog()
        //refreshControl.endRefreshing()
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
                        c.units = i["units"].stringValue
                        if let s = realm.object(ofType: ProductObject.self, forPrimaryKey: c.id) {
                            c.favorite = s.favorite
                        }
                        for j in i["icons"].arrayValue { c.icons.append(j.stringValue) }
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
                    for i in json["ingredients"].arrayValue {
                        let c = IngredientObject()
                        c.id = i["id"].intValue
                        c.title = i["title"].stringValue
                        c.weight = i["weight"].doubleValue
                        c.price = i["price"].doubleValue
                        c.icon = i["icon"].stringValue
                        realm.add(c, update: true)
                    }
                }
                //print(json)
            } catch {
                print("pizza.json not valid")
            }
        }
        refreshControl.endRefreshing()
    }
    
    func updateLayout(size: CGSize, animated: Bool) {
        
        let currentlayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            insets = collectionView!.safeAreaInsets
        }
        
        let columns = (size.width > size.height) ? 4 : 2 as CGFloat
        var width = (size.width-10-insets.left-insets.right-(columns-1)*2)/columns
        var height = width + 110
        if condencedLayout {
            width = size.width-insets.left-insets.right-8
            height = 104
        }
        let cellSize = CGSize(width: width, height: height)
        if currentlayout.itemSize == cellSize { return }

        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 2
        if #available(iOS 11.0, *) {
            layout.sectionInsetReference = .fromSafeArea
        }
        collectionView?.setCollectionViewLayout(layout, animated: animated)
    }
    
    @IBAction func addtocartAction(_ sender: UIButton) {
        
        let index = sender.tag
        let product = categories[currentCategory].products[index]
        let realm = try! Realm()
        if let samePurchase = purchases.filter("productId=\(product.id) AND productVariant=0").first {
            try! realm.write { samePurchase.productCount+=1 }
        } else {
            try! realm.write {
                let purchase = PurchaseObject()
                purchase.productId = product.id
                purchase.productVariant = 0
                purchase.productCount = 1
                realm.add(purchase)
            }
        }
        cartBadge = 0
        for i in purchases { cartBadge += i.productCount }
        if let items = tabBarController?.tabBar.items {
            if items.count > 3 {
                let item = items[3] as UITabBarItem
                item.badgeValue = "\(cartBadge)"
            }
        }
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        let index = sender.tag
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
        } else if segue.identifier == "ShowProductSegue" {
            let productController = segue.destination as! ProductController
            productController.product = categories[currentCategory].products[currentProduct]
        }
    }
    
    ///////////////////////////// Collection View Delegate ///////////////////////////////
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = categories[currentCategory].products.count
        if count == 0 {
            if let emptyView = Bundle.main.loadNibNamed("EmptyCollectionView", owner: self, options: nil)?.first as? EmptyCollectionView {
                collectionView.backgroundView = emptyView
            }
        } else {
            collectionView.backgroundView = nil
        }
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentProduct = indexPath.row
        performSegue(withIdentifier: "ShowProductSegue", sender: self)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let index = indexPath.row
        let product = categories[currentCategory].products[index]
        
        let formatter = NumberFormatter()
        formatter.decimalSeparator = ","
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.perMillSymbol = " "
        formatter.locale = Locale(identifier: "ru")

        if condencedLayout {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CondencedCell", for: indexPath) as! CondencedCell
            cell.tag = index
            cell.favoriteButton.tag = index
            cell.purchaseButton.tag = index
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.fullDescription
            if product.favorite {
                cell.favoriteButton.setImage(UIImage(named:"CellDarkStar"), for: .normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named:"CellLightStar"), for: .normal)
            }
            //cell.favoriteButton.isSelected = product.favorite
            if let url = URL(string: product.icons.first!) {
                DispatchQueue.main.async { cell.imageView.kf.setImage(with: url, placeholder:cell.imageView.image) }
            } else {
                cell.imageView.image = UIImage(named:"ImagePlaceholder")
            }
            if let variant = product.variants.first {
                let astring = NSMutableAttributedString(string: formatter.string(from: variant.price as NSNumber)!)

                //let astring = NSMutableAttributedString(string: "\(variant.price)")
                let size = cell.priceLabel.font.pointSize
                let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : cell.priceLabel.font.withSize(size*0.75)])
                astring.append(asuffix)
                cell.priceLabel.attributedText = astring
            }
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CatalogCell", for: indexPath) as! CatalogCell
            cell.tag = index
            cell.favoriteButton.tag = index
            cell.purchaseButton.tag = index
            cell.titleLabel.text = product.title
            cell.descriptionLabel.text = product.fullDescription
            if product.favorite {
                cell.favoriteButton.setImage(UIImage(named:"CellDarkStar"), for: .normal)
            } else {
                cell.favoriteButton.setImage(UIImage(named:"CellLightStar"), for: .normal)
            }
            //cell.favoriteButton.isSelected = product.favorite
            if let url = URL(string: product.icons.first!) {
                DispatchQueue.main.async { cell.imageView.kf.setImage(with: url, placeholder:cell.imageView.image) }
            } else {
                cell.imageView.image = UIImage(named:"ImagePlaceholder")
            }
            if let variant = product.variants.first {
                let astring = NSMutableAttributedString(string: formatter.string(from: variant.price as NSNumber)!)
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
