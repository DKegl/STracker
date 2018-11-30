//
//  EpisodesListVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

// Used to expand/collapse structure to show hide sections (Seasons and contained episodes)
struct ShowHideSection<T>{
    var isExpanded: Bool
    // Removed 29.11.2018
    // var episodes: [ShowEpisodenInformation]
    
    // Added 29.11.2018
    // One section contains an section number and assigned episodes
    var episodesBySection = [T]()
    // Added 29.11.2018
    mutating func expandSection(expand: Bool) {
        isExpanded = expand
    }
}

class EpisodesListVC:UITableViewController,UIViewControllerPreviewingDelegate {
    // Added 29.11.2018
    var expandableSections = [ShowHideSection<ShowEpisodenInformation>]()
   
    //Get from Search
    var showInfo: Int?
    
    //Get from bookmarkVC
    var bookmarkShow:RealmBookmarkShow?
    
    var showName: String!
    
    //Endpoint API
    var showepList = ShowEpListApi()
    
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
    
    func createGroupedEpisodes(episodes:[ShowEpisodenInformation])->[ShowHideSection<ShowEpisodenInformation>]{
        //Build an Dictionary Grouped by 'season'
        let groupedDictionary = Dictionary(grouping: episodes){$0.season!}
        
        // Get keys in sorted order (1,2,3...)
        let keys = groupedDictionary.keys.sorted()
        
        //Transfrom dictionay into grouped sections
        var groupedSections=[ShowHideSection<ShowEpisodenInformation>]()
        keys.forEach({ key in
            // Added 29.11.2018
            groupedSections.append(ShowHideSection(isExpanded: true, episodesBySection: groupedDictionary[key]!))
        })
        return groupedSections
    }
    
    func loadEpisodeListFromEndpointAPIWith(id:Int){
        // Read all episodes from show
        showepList.getEpList(id: id) { [unowned self] episoden in
            guard let episoden = episoden else {return}
            self.expandableSections=self.createGroupedEpisodes(episodes: episoden)
            // Refresh tableview
            self.tableView.reloadData()
        }
        
    }
    
    func loadEpisodeFromShowStoreManagerWith(show:RealmBookmarkShow){
        guard let episodes=ShowStoreManager.shared.episodesBy(bookmarkShow: show) else {return}
        expandableSections=createGroupedEpisodes(episodes:episodes)
          tableView.reloadData()
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
        
        return expandableRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodenCell") as! epCell
        
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
        // Added 29.11.2018
        // Invert seen flag by selecting the cell
        expandableSections[indexPath.section].episodesBySection[indexPath.row].seen = !(expandableSections[indexPath.section].episodesBySection[indexPath.row].seen ?? false)
        
        // Refresh modified rows(episodes) from tableview
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
}

// MARK: - Force Touch Preview

extension EpisodesListVC {
    @objc func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
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
    
    @objc(previewingContext:commitViewController:) func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
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
        
        // Added 29.11.2018
        let title = "Season \(expandableSections[section].episodesBySection[0].season!)"
        // Set header font stroke
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
        
        // Added 29.11.2018
        for row in expandableSections[expandSection].episodesBySection.indices {
            let index = IndexPath(row: row, section: expandSection)
            indexPaths.append(index)
        }
        // Prepare expandable sections
        let isExpanded = expandableSections[expandSection].isExpanded
        expandableSections[expandSection].expandSection(expand: !isExpanded)
                
        if isExpanded { // Yes, fold
            tableView.deleteRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        } else { // No - unfold
            tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        }
    }
}
