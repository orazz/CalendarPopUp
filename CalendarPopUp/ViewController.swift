//
//  ViewController.swift
//  CalendarPopUp
//
//  Created by Atakishiyev Orazdurdy on 11/16/16.
//  Copyright © 2016 Veriloft. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    var aPopupContainer: PopupContainer?
    var testCalendar = Calendar(identifier: Calendar.Identifier.iso8601)
    var currentDate: Date! = Date() {
        didSet {
            setDate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentDate = Date()
    }

    @IBAction func showCalendar(_ sender: UIButton) {
        let xibView = Bundle.main.loadNibNamed("CalendarPopUp", owner: nil, options: nil)?[0] as! CalendarPopUp
        xibView.calendarDelegate = self
        xibView.selected = currentDate
        xibView.startDate = Calendar.current.date(byAdding: .month, value: -12, to: currentDate)!
        xibView.endDate = Calendar.current.date(byAdding: .year, value: 2, to: currentDate)!
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
  
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        let monthName = GetHumanDate(month: month, language: .spanish) // DateFormatter().monthSymbols[(month-1) % 12] //
        let week = GetTurkmenWeek(weekDay: weekday, language: .spanish) // DateFormatter().shortWeekdaySymbols[weekday-1]
        let day = testCalendar.component(.day, from: currentDate)
        dateLabel.text = "\(week), " + monthName + " " + String(day)
    }
}

extension ViewController: CalendarPopUpDelegate {
    func dateChaged(date: Date) {
        currentDate = date
    }
}
