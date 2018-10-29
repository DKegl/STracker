//
//  ViewController.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 13.10.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import UIKit

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource{

    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet var tableView: UITableView!
    
    var showepList = ShowEpListApi()
    var showMainApi = ShowMainApi()
    var episodeArray = [ShowEpisodenInformation]()
    var showSearchArray = [ShowSearch]()
    var searchShowApi = ShowSearchAPI()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.topItem?.title = "Search a Show"
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {

        guard showSearchArray.count>0 else {return false}
        return true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueMainShowInformationVC"{
            guard let destinationVC = segue.destination as? MainShowInformationVC else {return}
            if let showMainCell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: showMainCell){
                destinationVC.showInfo = showSearchArray[indexPath.row]
            }
            
        }
    }
    
    // MARK: - TableView Protocols
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if showSearchArray.count == 0{
            return 1
        }
        return showSearchArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "ShowMainCell", for: indexPath)
        if showSearchArray.count == 0 {
            cell.textLabel?.text = "No matching shows please try again"
        } else {
        cell.textLabel?.text = showSearchArray[indexPath.row].show?.name ?? "No Shows"
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
            }
            else {
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


