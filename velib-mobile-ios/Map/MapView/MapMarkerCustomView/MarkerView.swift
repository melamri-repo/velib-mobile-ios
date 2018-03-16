//
//  MarkerView.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 16/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit
class MarkerView: UIView {
    // MARK: -Components
    @IBOutlet weak var velibNameLabel: UILabel!
    @IBOutlet weak var availableBikesLabel: UILabel!
    @IBOutlet weak var lastUpdateLabel: UILabel!
    /// instanciate view from nib
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MarkerView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
    }
    /// Set up Marker info
    ///
    /// - Parameter velib: <#velib description#>
    func setupInfoView(velib: VelibModel) {
        if let name = velib.name {
            velibNameLabel.text = name
        }
        if let availableBikes = velib.available_bikes, let bike_stands = velib.bike_stands {
            availableBikesLabel.text = String(availableBikes) + "/" + String(bike_stands)
        }
        if let date = velib.last_update {
            lastUpdateLabel.text = "Depuis : "+VelibHelper.sharedInstance.formatDate(withTimeStamp: date)
        }
        if velib.status?.lowercased() == StandStatus.open.rawValue.lowercased() {
            self.layer.borderColor = UIColor.green.cgColor
        } else {
            self.layer.borderColor = UIColor.red.cgColor
        }
        if let status = velib.status {
            self.layer.borderColor = VelibHelper.sharedInstance.colorFromVelibStatus(status: status).cgColor
        }
    }
    
}
