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
    let formatter = DateFormatter()
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        <#code#>
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        <#code#>
    }
}
