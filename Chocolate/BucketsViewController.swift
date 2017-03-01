//
//  BucketsViewController.swift
//  Chocolate
//
//  Created by Hans Sjunnesson on 23/12/15.
//  Copyright © 2015 Hans Sjunnesson. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

open class BucketsViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    fileprivate var renderedBuckets = [Int: CGImage]()
    
    override open func viewDidLoad() {
        super.viewDidLoad()

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    fileprivate func numberOfBuckets() -> (Int, Int) {
        if self.view.needsUpdateConstraints() {
            return (0, 0)
        }
        
        let width = Double(self.view.bounds.size.width)
        let height = Double(self.view.bounds.size.height)
        
        return (Int(width.truncatingRemainder(dividingBy: 64.0)), Int(height.truncatingRemainder(dividingBy: 64.0)))
    }
    
    
    open override func viewDidLayoutSubviews() {
        self.collectionView?.reloadData()
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let (rows, cols) = numberOfBuckets()
        return cols * rows
    }

    override open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = UIColor.red
        
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
    }
    */

    // MARK: UICollectionViewDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard
            self.view.needsUpdateConstraints(),
            let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return UIEdgeInsets.zero
        }
        
        let (rows, cols) = numberOfBuckets()
        let xInset = (collectionView.bounds.size.width - (CGFloat(cols) * flowLayout.itemSize.width)) / 2.0
        let yInset = (collectionView.bounds.size.height - (CGFloat(rows) * flowLayout.itemSize.height)) / 2.0
        
        return UIEdgeInsets(top: yInset, left: xInset, bottom: yInset, right: xInset)
    }
}
