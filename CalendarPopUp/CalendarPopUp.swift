//
//  CalendarPopUp.swift
//  CalendarPopUp
//
//  Created by Atakishiyev Orazdurdy on 11/16/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarPopUpDelegate: class {
    func dateChaged(date: Date)
}

class CalendarPopUp: UIView {
    
    @IBOutlet weak var calendarHeaderLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var dateLabel: UILabel!
    
    weak var calendarDelegate: CalendarPopUpDelegate?
    
    var endDate: Date!
    var startDate: Date = Date().getStart()
    
    var testCalendar = Calendar(identifier: .gregorian)
    var selectedDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    var selected:Date = Date() {
        didSet {
            calendarView.scrollToDate(selected)
            calendarView.selectDates([selected])
        }
    }
    
    @IBAction func closePopupButtonPressed(_ sender: AnyObject) {
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }
    
    @IBAction func GetDateOk(_ sender: Any) {
        calendarDelegate?.dateChaged(date: selectedDate)
        if let superView = self.superview as? PopupContainer {
            (superView ).close()
        }
    }
    
    override func awakeFromNib() {
        //Calendar
        // You can also use dates created from this function
        endDate = Calendar.current.date(byAdding: .month, value: 1, to: startDate)!
        setCalendar()
        setDate()
    }
    
    func setCalendar() {
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        calendarView.cellInset = CGPoint(x: 0, y: 0)
    }
    
    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate).month!
        
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)
        
        let year = testCalendar.component(.year, from: startDate)
        calendarHeaderLabel.text = monthName + ", " + String(year)
    }
 
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: selectedDate).month!
        let weekday = testCalendar.component(.weekday, from: selectedDate)
        
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        let week = DateFormatter().shortWeekdaySymbols[weekday-1]
        
        let day = testCalendar.component(.day, from: selectedDate)
        
        dateLabel.text = "\(week), " + monthName + " " + String(day)
    }
}

// MARK : JTAppleCalendarDelegate
extension CalendarPopUp: JTAppleCalendarViewDelegate, JTAppleCalendarViewDataSource {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: testCalendar, // This parameter will be removed in version 6.0.1
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        (cell as? CellView)?.handleCellSelection(cellState: cellState, date: date, selectedDate: selectedDate)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        selectedDate = date
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willResetCell cell: JTAppleDayCellView) {
        (cell as? CellView)?.selectedView.isHidden = true
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}

