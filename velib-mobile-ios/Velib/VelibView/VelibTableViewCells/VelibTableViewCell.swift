//
//  VelibTableViewCell.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit
import GoogleMaps

/// Custom TableViewCell for Velib TableView
class VelibTableViewCell: UITableViewCell{
    /// MARK: -Components
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    /// set up cell
    ///
    /// - Parameter velib: <#velib description#>
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
            dateLabel.text = "Depuis : "+VelibHelper.sharedInstance.formatDate(withTimeStamp: date)
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
