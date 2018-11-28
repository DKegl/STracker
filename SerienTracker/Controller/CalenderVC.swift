//
//  CalenderVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 24.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import JTAppleCalendar
import RealmSwift
import UIKit

class CalenderVC: UIViewController {
    @IBOutlet var yearLbl: UILabel!
    @IBOutlet var monthLbl: UILabel!
    @IBOutlet var calendarView: JTAppleCalendarView!
    @IBOutlet var dayCalendarView: UITableView!
    
    
    //Cell variable may later custom cel
    //
    //
    let formatter = DateFormatter()
    let currentDate = Date()
    var selectedDate: String = ""
    
    var showAtDateTable: Results<RealmEpisodenInformation>?

    //26.11.2018 - Realm is now part of ShowStoreManager
    lazy var showStore:ShowStoreManager={
         return ShowStoreManager.shared
    }()
    
//    lazy var realm: Realm = {
//       let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        return appDelegate.realm!
//    }()
//
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        setupCalendar()
        calendarView.scrollToDate(currentDate)
    }
    
    // load calendar wirh dates and remove spacing
    func setupCalendar() {
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    // set month and year Lbl
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLbl.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLbl.text = formatter.string(from: date)
    }
    
    // helper function for loading the dot which indicates there was a show airing
    func indicatorEpisodeAvailable(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCollectionCustomCell else { return }
        let date = cellState.date.description
        let cutdate: String = String(date.prefix(10))
        
        let showAtDate = showStore.filter(type: ShowStoreFilter.Episodes(airdate: cutdate))?.first
        
//        let showAtDate = realm.objects(RealmEpisodenInformation.self).filter("airdate == %@", cutdate).first
        
        if (showAtDate?.airdate) != nil {
            validCell.indicatorView.isHidden = false
        } else {
            validCell.indicatorView.isHidden = true
    } }
    
    // helper converting cellstate to string for searching the database
    func getCellDateAsString(view: JTAppleCell?, cellState: CellState) -> String {
        let date = cellState.date.description
        let cutdate: String = String(date.prefix(10))
        return cutdate
    }
    
    // color setup vor the calendar
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCollectionCustomCell else {
            return
        }
        
        if cellState.isSelected {
            validCell.dayLbl.textColor = turquoiseColor
        } else {
            if cellState.dateBelongsTo == .thisMonth {
                validCell.dayLbl.textColor = darkblack
            } else {
                validCell.dayLbl.textColor = blackColor
            }
        }
    }
}

// MARK: - Extensions for collectionView

extension CalenderVC: JTAppleCalendarViewDataSource {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        formatter.dateFormat = "yyyy MM dd"
        formatter.timeZone = Calendar.current.timeZone
        formatter.locale = Calendar.current.locale
        
        let startDate = formatter.date(from: "2017 01 01")!
        let endDate = formatter.date(from: "2022 12 31")!
        
        let parameters = ConfigurationParameters(startDate: startDate, endDate: endDate, firstDayOfWeek: .monday)
        
        return parameters
    }
}

extension CalenderVC: JTAppleCalendarViewDelegate {
    // not sure what this does but the readme says its needed :D
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CalendarCollectionCustomCell
        cell.dayLbl.text = cellState.text
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionCustomCell
        
        cell.dayLbl.text = cellState.text
        
        handleCellTextColor(view: cell, cellState: cellState)
        indicatorEpisodeAvailable(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        selectedDate = getCellDateAsString(view: cell, cellState: cellState)
        dayCalendarView.isHidden = false
        dayCalendarView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellTextColor(view: cell, cellState: cellState)
        dayCalendarView.isHidden = true
        dayCalendarView.reloadData()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLbl.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLbl.text = formatter.string(from: date)
    }
}

// MARK: - Extensions for TableView

extension CalenderVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if realm.objects(RealmEpisodenInformation.self).filter("airdate == %@", selectedDate).isEmpty {
//            return 0
//        } else {
//            showAtDateTable = realm.objects(RealmEpisodenInformation.self).filter("airdate == %@", selectedDate)
//            return showAtDateTable!.count
//        }
        
        if let isEmpty=showStore.filter(type: ShowStoreFilter.Episodes(airdate: selectedDate))?.isEmpty,
            isEmpty != true,
            let queryCount=showStore.filter(type: ShowStoreFilter.Episodes(airdate: selectedDate))?.count{
               return queryCount
        }else{
                return 0
       }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let showAtDate = realm.objects(RealmEpisodenInformation.self).filter("airdate == %@", selectedDate)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarTableViewCell", for: indexPath) as! CalendarTableViewCell
        
        guard let showAtDate=showStore.filter(type: ShowStoreFilter.Episodes(airdate: selectedDate)) else {return cell}
        
        let show = showAtDate[indexPath.row]
        cell.setShowAtDay(show: show)
//        cell.textLabel?.text = showAtDate[indexPath.row].name
//        cell.detailTextLabel?.text = showAtDate[indexPath.row].show?.showName
        return cell
        }
    }

extension CalenderVC: UITableViewDelegate {}




