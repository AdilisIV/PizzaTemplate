//
//  CategoryController.swift
//  Pizza
//
//  Created by Alexander Kosse on 23/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher

class CategoryController: UICollectionViewController {

    private var firstLaunch = true
    private let categories = try! Realm().objects(CategoryObject.self)
    public var currentCategory = 0
    weak var catalogController: CatalogController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 11.0, *) { collectionView?.insetsLayoutMarginsFromSafeArea = true }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        updateLayout(size: collectionView!.bounds.size, animated: false)
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        if firstLaunch {
            firstLaunch = false
            insets = UIEdgeInsets(top: navigationController!.navigationBar.intrinsicContentSize.height, left: 0, bottom: 49, right: 0)
            if #available(iOS 11.0, *) {} else { insets.top += 20 }
        }
        collectionView?.contentInset = insets
        collectionView?.scrollIndicatorInsets = insets
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        currentCategory = indexPath.row
        catalogController?.currentCategory = currentCategory
        catalogController?.collectionView?.reloadData()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
    
    func updateLayout(size: CGSize, animated: Bool) {
        let currentlayout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        var insets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) { insets = collectionView!.safeAreaInsets }
        
        let columns = (size.width > size.height) ? 4 : 2 as CGFloat
        let width = (size.width-10-insets.left-insets.right-(columns-1)*2)/columns
        let height = width + 20
        let cellSize = CGSize(width: width, height: height)
        if currentlayout.itemSize == cellSize { return }
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 6, left: 4, bottom: 6, right: 4)
        layout.minimumLineSpacing = 4
        layout.minimumInteritemSpacing = 2
        if #available(iOS 11.0, *) { layout.sectionInsetReference = .fromSafeArea }
        collectionView?.setCollectionViewLayout(layout, animated: animated)
    }

    ///////////////////////////// Collection View Delegate & Datasource ///////////////////////////////
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        cell.categoryTitleLabel.text = categories[indexPath.row].title
        if let url = URL(string: self.categories[indexPath.row].icon) {
            DispatchQueue.main.async { cell.categoryImageView.kf.setImage(with: url) }
        } else {
            cell.categoryImageView.image = UIImage(named:"ImagePlaceholder")
        }

        return cell
    }
    
    override func viewSafeAreaInsetsDidChange() {
        updateLayout(size: collectionView!.bounds.size, animated: false)
    }
}
