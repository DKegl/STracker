//
//  EpisodesListVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 20.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

// Used to expand/collapse episodes in season sections'
struct ShowHideEpsiodes {
    var isExpanded: Bool
    var episodes: [ShowEpisodenInformation]
}

class EpisodesListVC: UITableViewController, UIViewControllerPreviewingDelegate {
    var showInfo: Int?
    var showName: String!
    
    var showepList = ShowEpListApi()
    
    // Holds episodes grouped by seasons
    // >> var groupedEpisodes = [[ShowEpisodenInformation]]()
    var expandableGroupedEpisodes = [[ShowHideEpsiodes]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Disable lines between cells
        tableView.separatorStyle = .none
        
        navigationItem.title = showName
        // check if force Touch availible
        
        if traitCollection.forceTouchCapability == UIForceTouchCapability.available {
            registerForPreviewing(with: self, sourceView: view)
        } else {
            print("no force touch on this device")
        }
        
        // Read all episodes from show
        showepList.getEpList(id: showInfo!) { [weak self] episoden in
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
                    
                    self?.expandableGroupedEpisodes.append([ShowHideEpsiodes(isExpanded: true, episodes: groupedDictionary[key]!)])
                })
                
                // Refresh tableview
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return expandableGroupedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // number of episodes in seasons (section points to actual season)
        
        let expandedRows = expandableGroupedEpisodes[section][0].isExpanded ? expandableGroupedEpisodes[section][0].episodes.count : 0
        
        return expandedRows
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "episodenCell") as! epCell
        
        // Get episode from season(section) and row
        let episode = expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row]
        
       
        cell.setEp(episode: episode)
        
        // Checkmark seen episodes
        if episode.seen == true {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Checkmark seen episode
        // >> groupedEpisodes[indexPath.section][indexPath.row].seen = !(groupedEpisodes[indexPath.section][indexPath.row].seen ?? false)
        
        expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row].seen = !(expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row].seen ?? false)
        
        // Refresh modified rows(episodes) from tableview
        tableView.reloadRows(at: [indexPath], with: UITableView.RowAnimation.none)
    }
    
    // MARK: - Force Touch Preview
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        // Obtain the index path and the cell that was pressed.
        guard let indexPath = tableView.indexPathForRow(at: location),
            let cell = tableView.cellForRow(at: indexPath) else { return nil }
        
        // Create a detail view controller and set its properties.
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "preview") as? previewViewController else { return nil }
        
        let previewDetail = expandableGroupedEpisodes[indexPath.section][0].episodes[indexPath.row]
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
        let title = "Season \(expandableGroupedEpisodes[section][0].episodes[0].season!)"
        
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
        for row in expandableGroupedEpisodes[expandSection][0].episodes.indices {
            let index = IndexPath(row: row, section: expandSection)
            indexPaths.append(index)
        }
        
        // Get expand flag
        let isExpanded = expandableGroupedEpisodes[expandSection][0].isExpanded
        // Revert it
        expandableGroupedEpisodes[expandSection][0].isExpanded = !isExpanded
        
        if isExpanded { // Yes, fold
            tableView.deleteRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        } else { // No - unfold
            tableView.insertRows(at: indexPaths, with: UITableView.RowAnimation.fade)
        }
    }
}
