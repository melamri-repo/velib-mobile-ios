//
//  VelibTableViewCell.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit

class VelibTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    func setupCell(velib: VelibModel) {
        if let name = velib.name {
            if !name.isEmpty {
                nameLabel.text = name
            }
        }
        if let availableBikes = velib.available_bikes, let bike_stands = velib.bike_stands {
            numberLabel.text = String(availableBikes) + "/" + String(bike_stands)
        }
        if let status = velib.status {
            statusLabel.text = status
        }
        if let date = velib.last_update {
            dateLabel.text = "Depuis : "+formatDate(withTimeStamp: date)
        }
    }
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
}
