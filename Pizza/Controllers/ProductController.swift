//
//  ProductController.swift
//  Pizza
//
//  Created by Alexander Kosse on 16/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit
import RealmSwift

class ProductController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var prevImageButton: UIButton!
    @IBOutlet weak var nextImageButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var sizeControl: UISegmentedControl!
    @IBOutlet weak var doughControl: UISegmentedControl!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var configurationConstraint: NSLayoutConstraint!
    
    private let sizes = try! Realm().objects(SizeObject.self)
    private let doughs = try! Realm().objects(DoughObject.self)
    private let purchases = try! Realm().objects(PurchaseObject.self)
    
    var selectedDough = 1
    var selectedSize = 1

    var product: ProductObject? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        shadowView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        shadowView.layer.shadowRadius = 3.0
        shadowView.layer.shadowOpacity = 1.0
        shadowView.layer.masksToBounds = false
        
        blankView.layer.cornerRadius = 4.0
        blankView.layer.borderWidth = 1.0
        blankView.layer.borderColor = UIColor.clear.cgColor
        blankView.layer.masksToBounds = true

        gallery.addObserver(self, forKeyPath: "contentSize", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    @IBAction func favoriteAction(_ sender: UIButton) {
        if product != nil {
            let realm = try! Realm()
            try! realm.write {
                product!.favorite = !product!.favorite
            }
            updateProductView()
        }
    }
    
    @IBAction func addtocartAction(_ sender: UIButton) {
        var variantIndex = 0
        if product != nil {
            for i in 0 ..< product!.variants.count {
                if let size = product?.variants[i].size, let dough = product?.variants[i].dough {
                    if size == selectedSize && dough == selectedDough {
                        variantIndex = i
                        break
                    }
                }
            }
            let realm = try! Realm()
            if let samePurchase = purchases.filter("productId=\(product!.id) AND productVariant=\(variantIndex)").first {
                try! realm.write { samePurchase.productCount += 1 }
            } else {
                try! realm.write {
                    let purchase = PurchaseObject()
                    purchase.productId = product!.id
                    purchase.productVariant = variantIndex
                    purchase.productCount = 1
                    realm.add(purchase)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateProductView()
        updateLayout(size: gallery.frame.size, animated: false)
    }
    
    @IBAction func doughChanged(_ sender: UISegmentedControl) {
        selectedDough = sender.selectedSegmentIndex + 1
        updateProductView()
    }
    
    @IBAction func sizeChanged(_ sender: UISegmentedControl) {
        selectedSize = sender.selectedSegmentIndex + 1
        updateProductView()
    }
    
    func updateProductView() {
        
        if product != nil {
            
            let formatter = NumberFormatter()
            formatter.decimalSeparator = ","
            formatter.numberStyle = .decimal
            formatter.maximumFractionDigits = 2
            formatter.perMillSymbol = " "
            formatter.locale = Locale(identifier: "ru")

            titleLabel.text = product!.title
            navigationItem.title = product!.title
            descriptionLabel.text = product!.fullDescription
            if product!.favorite {
                favoriteButton.setImage(UIImage(named:"CellDarkStar"), for: .normal)
            } else {
                favoriteButton.setImage(UIImage(named:"CellLightStar"), for: .normal)
            }
            if product!.variants.count > 1 {
                for size in sizes {
                    if size.id - 1 < sizes.count {
                        sizeControl.setTitle(size.title, forSegmentAt: size.id-1)
                    }
                }
                sizeControl.selectedSegmentIndex = selectedSize - 1
                for dough in doughs {
                    if dough.id - 1 < doughs.count {
                        doughControl.setTitle(dough.title, forSegmentAt: dough.id-1)
                    }
                }
                doughControl.selectedSegmentIndex = selectedDough - 1
                let variant = product!.variants.filter { $0.size == self.selectedSize && $0.dough == self.selectedDough }.first
                if variant != nil {
                    weightLabel.text = formatter.string(from: variant!.weight as NSNumber)! + " " + product!.units
                    let astring = NSMutableAttributedString(string: formatter.string(from: variant!.price as NSNumber)!)
                    let size = priceLabel.font.pointSize
                    let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : priceLabel.font.withSize(size*0.75)])
                    astring.append(asuffix)
                    priceLabel.attributedText = astring
                }
            } else if product!.variants.count > 0 {
                let variant = product!.variants.first!
                weightLabel.text = formatter.string(from: variant.weight as NSNumber)! + " " + product!.units
                let astring = NSMutableAttributedString(string: formatter.string(from: variant.price as NSNumber)!)
                let size = priceLabel.font.pointSize
                let asuffix = NSAttributedString(string: " ₽", attributes:[NSAttributedStringKey.font : priceLabel.font.withSize(size*0.75)])
                astring.append(asuffix)
                priceLabel.attributedText = astring
                configurationConstraint.constant = 0
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        let layout = gallery.collectionViewLayout as! UICollectionViewFlowLayout
        if layout.itemSize != gallery.frame.size {
            updateLayout(size: gallery.frame.size, animated: false)
        }
    }
    
    func updateLayout(size: CGSize, animated: Bool) {
        //print(size)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = size
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        gallery.setCollectionViewLayout(layout, animated: animated)
        gallery.scrollToItem(at: IndexPath(row: 0, section: 0), at: UICollectionViewScrollPosition.left, animated: false)
    }

    @IBAction func prevImageAction(_ sender: UIButton) {
        var index = Int(floor(gallery.contentOffset.x/gallery.frame.size.width)) - 1
        if index < 0 { index = 0 }
        gallery.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    @IBAction func nextImageAction(_ sender: UIButton) {
        if product == nil { return }
        var index = Int(ceil(gallery.contentOffset.x/gallery.frame.size.width)) + 1
        if index >= product!.icons.count { index = product!.icons.count - 1 }
        gallery.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    private func updateButtons(_ scrollView: UIScrollView) {
        if scrollView == gallery {
            prevImageButton.isHidden = scrollView.contentOffset.x <= scrollView.frame.size.width * 0.5
            nextImageButton.isHidden = scrollView.contentOffset.x >= scrollView.contentSize.width-scrollView.frame.size.width * 1.5
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentSize" {
            updateButtons(gallery)
        }
    }
    
    ///////////////////////////// Collection View Delegate ///////////////////////////////
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if product != nil { return product!.icons.count }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        let index = indexPath.row
        if product != nil {
            if index < product!.icons.count {
                //print(product!.icons[index])
                if let url = URL(string: product!.icons[index]) {
                    DispatchQueue.main.async { cell.imageView.kf.setImage(with: url, placeholder:UIImage(named:"ImagePlaceholder")) }
                    return cell
                }
            }
        }
        cell.imageView.image = UIImage(named:"ImagePlaceholder")
        return cell
    }
    
    deinit {
        gallery.removeObserver(self, forKeyPath: "contentSize")
    }
}
