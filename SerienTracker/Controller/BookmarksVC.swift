//
//  BookmarksVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 11.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

private let reuseIdentifier = "bookmarkCell"

class BookmarksVC: UICollectionViewController {
    
    var allowEpisodeSegue: Bool=true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.reloadData()

        // Register cell classes is StoryBoard responsibility when using IB !!
        // self.collectionView!.register(bookmarkCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    

    override func viewWillAppear(_ animated: Bool) {
        // Reload data because database may have changed
        collectionView.reloadData()
        
        title = "Bookmarked Shows"
        setupViews()
    }
    
    //Configure subviews
    //Added 07.12.2018
    func setupViews(){
        collectionView.backgroundColor=greyColor
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }

    // MARK: UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return ShowStoreManager.shared.bookmarkShows.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! bookmarkCell

        // Configure the cell
        let bookmarkShows = ShowStoreManager.shared.bookmarkShows
        guard bookmarkShows.count > 0 else { return cell }
        cell.backgroundColor = greyColor
        cell.delegate = self
        cell.name = bookmarkShows[indexPath.row].showName
        cell.setBookmarkCell(show: bookmarkShows[indexPath.row])

        return cell
    }
}

extension BookmarksVC {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {}
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return allowEpisodeSegue
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "episodesFromBookmarkShow" {
            guard let selectedShowCellIndex = collectionView.indexPathsForSelectedItems?.first else { return }
            let bookmarkShow = ShowStoreManager.shared.bookmarkShows[selectedShowCellIndex.item]
            (segue.destination as! EpisodesListVC).bookmarkShow = bookmarkShow
        }
    }
}

extension BookmarksVC: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: 130)
    }
}

extension BookmarksVC: bookmarkCellDelegate {
    func deleteBookmark() {
        //Does nothing at the moment
    }
    

    func shareBtnTapped(name: String) {
        let ac = UIActivityViewController(activityItems: ["My new Favorite Show: ", name], applicationActivities: nil)
        present(ac, animated: true, completion: nil)
    }
}
