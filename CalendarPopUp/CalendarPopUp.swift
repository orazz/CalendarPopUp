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
        endDate = Calendar.current.date(byAdding: .month, value: 2, to: startDate)!
        setCalendar()
        setDate()
        self.calendarView.visibleDates {[unowned self] (visibleDates: DateSegmentInfo) in
            self.setupViewsOfCalendar(from: visibleDates)
        }
        
    }

    func setDate() {
        let month = testCalendar.dateComponents([.month], from: selectedDate).month!
        let weekday = testCalendar.component(.weekday, from: selectedDate)
        
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)
        let week = DateFormatter().shortWeekdaySymbols[weekday-1] //GetTurkmenWeek(weekDay: weekday)
        
        let day = testCalendar.component(.day, from: selectedDate)
        
        dateLabel.text = "\(week), " + monthName + " " + String(day)
    }

    func setupViewsOfCalendar(from visibleDates: DateSegmentInfo) {
        guard let startDate = visibleDates.monthDates.first?.date else {
            return
        }
        let month = testCalendar.dateComponents([.month], from: startDate)
        let monthName = DateFormatter().monthSymbols[Int(month.month!)-1] //GetHumanDate(month: month)
        
        let year = testCalendar.component(.year, from: startDate)
        calendarHeaderLabel.text = monthName + ", " + String(year)
    }
    
    func setCalendar() {
        calendarView.calendarDataSource = self
        calendarView.calendarDelegate = self
        let nibName = UINib(nibName: "CellView", bundle:nil)
        calendarView.register(nibName, forCellWithReuseIdentifier: "CellView")
        calendarView.minimumLineSpacing = 0
        calendarView.minimumInteritemSpacing = 0
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
                                                 calendar: testCalendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: DaysOfWeek.monday)

        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        (cell as? CellView)?.handleCellSelection(cellState: cellState, date: date, selectedDate: selectedDate)
    }
    
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let myCustomCell = calendar.dequeueReusableCell(withReuseIdentifier: "CellView", for: indexPath) as! CellView
        myCustomCell.handleCellSelection(cellState: cellState, date: date, selectedDate: selectedDate)
        return myCustomCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        selectedDate = date
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }

    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        (cell as? CellView)?.cellSelectionChanged(cellState, date: date)
    }

    func calendar(_ calendar: JTAppleCalendarView, willResetCell cell: JTAppleCell) {
        (cell as? CellView)?.selectedView.isHidden = true
    }

    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.setupViewsOfCalendar(from: visibleDates)
    }
}

