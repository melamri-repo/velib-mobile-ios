//
//  VelibHelper.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 16/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import Foundation
import UIKit
class VelibHelper {
    static var sharedInstance = VelibHelper()
    func formatDate(withTimeStamp numberOfSeconds: Int) -> String {
        let timestamp = numberOfSeconds != 0 ? Int(numberOfSeconds) : Int(0.0)
        let timeInterval: TimeInterval = CDouble(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateformatter = DateFormatter()
        dateformatter.locale = NSLocale.current
        let format = "HH:mm dd.MM.yyyy" //date format is based on the cell example from the PDF
        dateformatter.dateFormat = format
        return dateformatter.string(from: date)
    }
    func colorFromVelibStatus(status: String) -> UIColor {
        switch status {
        case "CLOSED":
            return UIColor.red
        case "OPEN":
            return UIColor.green
        default:
            return UIColor.white
        }
    }
}
