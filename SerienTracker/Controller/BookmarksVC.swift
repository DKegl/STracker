//
//  BookmarksVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 11.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookmarkCell"


class BookmarksVC: UICollectionViewController{

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setTabBarEmbeddedTitle(title: "Bookmark show")

        // Register cell classes
        self.collectionView!.register(bookmarkCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    
        
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

}



extension BookmarksVC:UICollectionViewDelegateFlowLayout{
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         return CGSize(width: self.collectionView.bounds.width, height:120)
    }
}


