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
    var testCalendar = Calendar(identifier: .gregorian)
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
        PopupContainer.generatePopupWithView(xibView).show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
  
    func setDate() {
        let month = testCalendar.dateComponents([.month], from: currentDate).month!
        let weekday = testCalendar.component(.weekday, from: currentDate)
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] //GetHumanDate(month: month)//
        let week = DateFormatter().shortWeekdaySymbols[weekday-1]
        
        let day = testCalendar.component(.day, from: currentDate)
        
        dateLabel.text = "\(week), " + monthName + " " + String(day)
    }
}

extension ViewController: CalendarPopUpDelegate {
    func dateChaged(date: Date) {
        currentDate = date
    }
}
