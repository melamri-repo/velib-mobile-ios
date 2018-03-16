//
//  PositionModel.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit

struct PositionModel: Codable {
    let lat: Double?
    let lng: Double?
    /// CodingKeys
    enum CodingKeys: String, CodingKey {
        case lat
        case lng
    }
    /// init from decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: error
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        lat = try values.decodeIfPresent(Double.self, forKey: .lat)
        lng = try values.decodeIfPresent(Double.self, forKey: .lng)
    }
    /// Encode
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: error
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lat, forKey: .lat)
        try container.encode(lng, forKey: .lng)
    }
}
