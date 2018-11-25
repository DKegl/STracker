//
//  CalenderVC.swift
//  SerienTracker
//
//  Created by Daniel Keglmeier on 24.11.18.
//  Copyright © 2018 Daniel Keglmeier. All rights reserved.
//

import JTAppleCalendar
import UIKit

class CalenderVC: UIViewController {
    @IBOutlet var yearLbl: UILabel!
    @IBOutlet var monthLbl: UILabel!
    @IBOutlet var calendarView: JTAppleCalendarView!
    
    let formatter = DateFormatter()
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.calendarDelegate = self
        calendarView.calendarDataSource = self
        setupCalendar()
        calendarView.scrollToDate(currentDate)
    }
    
    func setupCalendar() {
        calendarView.minimumInteritemSpacing = 0
        calendarView.minimumLineSpacing = 0
        
        calendarView.visibleDates { visibleDates in
            self.setupViewsOfCalendar(from: visibleDates)
        }
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLbl.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLbl.text = formatter.string(from: date)
    }
    
    func handleCellSelected(view: JTAppleCell?, cellState: CellState) {
        guard let validCell = view as? CalendarCollectionCustomCell else { return }
        if cellState.isSelected {
            validCell.indicatorView.isHidden = false
        } else {
            validCell.indicatorView.isHidden = true
        }
    }
    
    func handleCellTextColor(view: JTAppleCell?, cellState: CellState) {
        
        guard let validCell = view as? CalendarCollectionCustomCell  else {
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
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        let cell = cell as! CalendarCollectionCustomCell
        cell.dayLbl.text = cellState.text
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCollectionViewCell", for: indexPath) as! CalendarCollectionCustomCell
        cell.dayLbl.text = cellState.text
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleCellSelected(view: cell, cellState: cellState)
        handleCellTextColor(view: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        let date = visibleDates.monthDates.first!.date
        formatter.dateFormat = "yyyy"
        yearLbl.text = formatter.string(from: date)
        
        formatter.dateFormat = "MMMM"
        monthLbl.text = formatter.string(from: date)
    }
}
