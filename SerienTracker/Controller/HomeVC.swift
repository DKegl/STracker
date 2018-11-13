//
//  ViewController.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import Lottie
import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet var lottieView: LOTAnimationView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    var showepList = ShowEpListApi()
    var showMainApi = ShowMainApi()
    var episodeArray = [ShowEpisodenInformation]()
    var showSearchArray = [ShowSearch]()
    var searchShowApi = ShowSearchAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.topItem?.title = "Search a Show"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isHidden = true
        lottieView.setAnimation(named: "search")
        lottieView.play()
        lottieView.loopAnimation = true
        tableView.separatorStyle = .none // <<
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard showSearchArray.count > 0 else { return false }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMainShowInformationVC" {
            guard let destinationVC = segue.destination as? MainShowInformationVC else { return }
            if let showMainCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: showMainCell) {
                destinationVC.showInfo = showSearchArray[indexPath.row]
            }
        }
    }
    
    // MARK: - TableView Protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchArray.count == 0 {
            return 1
        }
        return showSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMainCell", for: indexPath) as! mainCell // <<
        
        let cellInfo: String
        if showSearchArray.count == 0 {
            cellInfo = "No matching shows please try again"
        } else {
            cellInfo = showSearchArray[indexPath.row].show?.name ?? "No Shows"
        }
        cell.setMainCell(cellInfo: cellInfo)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 5
    }
}

// MARK: - Searchbar Functions

extension HomeVC: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let name = searchBar.text!
        var formattedStringName = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        formattedStringName = formattedStringName.replacingOccurrences(of: " ", with: "-")
        searchBar.endEditing(true) // hides the keyboard after clicking searchbutton
        searchShowApi.searchShowJson(name: formattedStringName) { [weak self] showSearch in
            if showSearch != nil {
                self?.showSearchArray = showSearch!
                self!.tableView.reloadData()
                self?.lottieView.isHidden = true
                self?.tableView.isHidden = false
            } else {
                return
            }
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text! = ""
        DispatchQueue.main.async {
            searchBar.resignFirstResponder()
        }
    }
}
