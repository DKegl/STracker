//
//  EpisodesListVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

// Used to expand/collapse structure to show hide sections (Seasons and contained episodes)
struct ShowHideSection {
    var isExpanded: Bool
    // Removed 29.11.2018
    // var episodes: [ShowEpisodenInformation]
    
    // Added 29.11.2018
    // One section contains an section number and assigned episodes
    var episodesBySection = [ShowEpisodenInformation]()
    // Added 29.11.2018
    mutating func expandSection(expand: Bool) {
        isExpanded = expand
    }
}

class EpisodesListVC: UITableViewController, UIViewControllerPreviewingDelegate {
    //Get from Search
    var showInfo: Int?
    
    //Get from bookmark
    var bookmarkShow:RealmBookmarkShow?
    
    var showName: String!
    
    //Endpoint API
    var showepList = ShowEpListApi()
    
    // >> var groupedEpisodes = [[ShowEpisodenInformation]]()
    
    // Removed 29.11.2018
    // var expandableGroupedEpisodes = [[ShowHideSection]]()
    
    // Added 29.11.2018
    var expandableSections = [ShowHideSection]()
    
    func setupUI(){
        // Disable lines between cells
        tableView.separatorStyle = .none
        //Set title
        navigationItem.title = showName
    }
    
    func forceTouchAvailable()->Bool{
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self, sourceView: view)
            return true
        } else {
            print("no force touch on this device")
        }
        return false
    }
    
    func loadEpisodeListFromEndpointAPIWith(id:Int){
        // Read all episodes from show
        showepList.getEpList(id: id) { [unowned self] episoden in
            if let episoden = episoden {
                // Create dictionary for each season
                let groupedDictionary = Dictionary(grouping: episoden) { (episode) -> Int in
                    return episode.season!
                }
                
                // Get keys in sorted order (1,2,3...)
                let keys = groupedDictionary.keys.sorted()
                
                // Fill array for each key
                // groupedEpisodes[season n][episode n]
                keys.forEach({ key in
                    
                    // Removed 29.11.2018
                    
                    //   self?.expandableGroupedEpisodes.append([ShowHideEpsiodes(isExpanded: true, episodes: groupedDictionary[key]!)])
                    
                    // Added 29.11.2018
                    self.expandableSections.append(ShowHideSection(isExpanded: true, episodesBySection: groupedDictionary[key]!))
                })
                
                // Refresh tableview
                self.tableView.reloadData()
            }
        }
    }
    
    func loadEpisodeFromShowStoreManagerWith(show:RealmBookmarkShow){
       
        //>>>>>>>>>>>>>>>>>>   ToDo >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
        //just for fun...
        print(show)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        _=forceTouchAvailable()
        
        //Check if show is bookmarked
        if let bookmarkShow=self.bookmarkShow{
            loadEpisodeFromShowStoreManagerWith(show: bookmarkShow)
        }else{//Load from endpoint
            guard let showInfo=self.showInfo else {return}
            loadEpisodeListFromEndpointAPIWith(id: showInfo)
        }
        
    }
}

// MARK: - TableView DataSource methods

extension EpisodesListVC {
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Added 29.11.2018
        return expandableSections.count
        
        // Removed 29.11.2018
        // return expandableGroupedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of episodes in seasons (section points to actual season)
        
        // Added 29.11.2018
        let expandableRows = expandableSections[section].isExpanded ? expandableSections[section].episodesBySection.count : 0
        
        // Removed 29.11.2018
        // let expandableRows = expandableGroupedEpisodes[section][0].isExpanded ? expandableGroupedEpisodes[section][0].episodes.count : 0
        
        return expandableRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodenCell") as! epCell
        
        // Rremoved 29.11.2018
        // Get episode from season(section) and row
        // let episode = expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row]
        
        // Added 29.11.2018
        let episode = expandableSections[indexPath.section].episodesBySection[indexPath.row]
        
        cell.setEp(episode: episode)
        
        // >> ToDo Checkmark seen episodes
        if episode.seen == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - TableView delegate method

extension EpisodesListVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Checkmark seen episode
        // >> groupedEpisodes[indexPath.section][indexPath.row].seen = !(groupedEpisodes[indexPath.section][indexPath.row].seen ?? false)
        
        // >> Todo read value from realm database
        
        // Invert seen flag when selected
        // Removed 29.11.2018
        //        expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row].seen = !(expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row].seen ?? false)
        
        // Added 29.11.2018
        // Invert seen flag by selecting the cell
        expandableSections[indexPath.section].episodesBySection[indexPath.row].seen = !(expandableSections[indexPath.section].episodesBySection[indexPath.row].seen ?? false)
        
        //
        // Refresh modified rows(episodes) from tableview
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
}

// MARK: - Force Touch Preview

extension EpisodesListVC {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        // Create a detail view controller and set its properties.
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "preview") as? previewViewController else { return nil }
        
        // Removed 29.11.2018
        // let previewDetail = expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row]
        let previewDetail = expandableSections[indexPath.section].episodesBySection[indexPath.row]
        
        detailViewController.episodenDetail = previewDetail
        
        previewingContext.sourceRect = cell.frame
        
        return detailViewController
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //        let detailView = storyboard?.instantiateViewController(withIdentifier: "detailEpisode")
        //        show(detailView!, sender: self)
    }
}

// MARK: - Expandable section headers (show/hides episodes)

extension EpisodesListVC {
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // Set height of section header to get more touch area
        return 30
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // The view is a button
        let titleButton = UIButton()
        
        // Use the globally used text style to show the Season sections
        // >> let title = "Season \(groupedEpisodes[section][0].season!)"
        
        // Removed 29.11.2018
        // let title = "Season \(expandableGroupedEpisodes[section][0].episodes[0].season!)"
        
        // Added 29.11.2018
        let title = "Season \(expandableSections[section].episodesBySection[0].season!)"
        
        let strokeTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Futura", size: 12)!
        ] as [NSAttributedString.Key: Any]
        let attributedTitle = NSAttributedString(string: title, attributes: strokeTextAttributes)
        
        titleButton.setAttributedTitle(attributedTitle, for: .normal)
        
        // Put section(season number) into button tag to evaluate which section
        // should be expand/collapsed
        titleButton.tag = section
        
        // Epand/collapse target method
        titleButton.addTarget(self, action: #selector(expandEpisodesInSeason(_:)), for: UIControl.Event.touchUpInside)
        
        return titleButton
    }
    
    @objc func expandEpisodesInSeason(_ sender: UIButton) {
        // Get section(season) to show/hide
        let expandSection = sender.tag
        
        // get all episodes from season
        var indexPaths = [IndexPath]()
        
        // Removed 29.11.2018
        //        for row in expandableGroupedEpisodes[expandSection][0].episodes.indices {
//            let index = IndexPath(row: row, section: expandSection)
//            indexPaths.append(index)
//        }
        // Added 29.11.2018
        for row in expandableSections[expandSection].episodesBySection.indices {
            let index = IndexPath(row: row, section: expandSection)
            indexPaths.append(index)
        }
        // Prepare expandable sections
        let isExpanded = expandableSections[expandSection].isExpanded
        expandableSections[expandSection].expandSection(expand: !isExpanded)
        
        // Removed 29.11.2018
//        // Get expand flag
//        let isExpanded = expandableGroupedEpisodes[expandSection][0].isExpanded
//        // Revert it
//        expandableGroupedEpisodes[expandSection][0].isExpanded = !isExpanded
        
        if isExpanded { // Yes, fold
            tableView.deleteRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        } else { // No - unfold
            tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        }
    }
}
