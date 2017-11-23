//
//  ProductController.swift
//  Pizza
//
//  Created by Alexander Kosse on 16/11/2017.
//  Copyright © 2017 Information Technologies, LLC. All rights reserved.
//

import UIKit

class ProductController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var blankView: UIView!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var gallery: UICollectionView!
    @IBOutlet weak var prevImageButton: UIButton!
    @IBOutlet weak var nextImageButton: UIButton!
    
    let images = ["Pizza","Pizza2","Pizza3"]
    
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
    }

    @IBAction func prevImageAction(_ sender: UIButton) {
        var index = Int(floor(gallery.contentOffset.x/gallery.frame.size.width)) - 1
        if index < 0 { index = 0 }
        gallery.scrollToItem(at: IndexPath(row: index, section: 0), at: UICollectionViewScrollPosition.centeredHorizontally, animated: true)
    }
    
    @IBAction func nextImageAction(_ sender: UIButton) {
        var index = Int(ceil(gallery.contentOffset.x/gallery.frame.size.width)) + 1
        if index >= images.count { index = images.count - 1 }
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.imageView.image = UIImage(named:images[indexPath.row])
        return cell
    }
    
    deinit {
        gallery.removeObserver(self, forKeyPath: "contentSize")
    }
}
