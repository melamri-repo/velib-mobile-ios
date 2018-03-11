//
//  VelibModel.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import Foundation
import UIKit

struct VelibModel: Codable {
    let number: Int?
    let name: String?
    let address: String?
    let banking: Bool?
    let bonus: Bool?
    let status: String?
    let bike_stands: Int?
    let available_bike_stands: Int?
    let available_bikes: Int?
    let last_update: Int?
    let position: PositionModel?
    /// CodingKeys
    enum CodingKeys: String, CodingKey {
        case number
        case name
        case address
        case banking
        case bonus
        case status
        case bike_stands
        case available_bike_stands
        case available_bikes
        case last_update
        case position
    }
    /// init from decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: error
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        number = try values.decodeIfPresent(Int.self, forKey: .number)
        name = try values.decodeIfPresent(String.self, forKey: .name)
        address = try values.decodeIfPresent(String.self, forKey: .address)
        banking = try values.decodeIfPresent(Bool.self, forKey: .banking)
        bonus = try values.decodeIfPresent(Bool.self, forKey: .bonus)
        status = try values.decodeIfPresent(String.self, forKey: .status)
        bike_stands = try values.decodeIfPresent(Int.self, forKey: .bike_stands)
        available_bike_stands = try values.decodeIfPresent(Int.self, forKey: .available_bike_stands)
        available_bikes = try values.decodeIfPresent(Int.self, forKey: .available_bikes)
        last_update = try values.decodeIfPresent(Int.self, forKey: .last_update)
        position = try values.decodeIfPresent(PositionModel.self, forKey: .position)
    }
    /// Encode
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: error
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(banking, forKey: .banking)
        try container.encode(bonus, forKey: .bonus)
        try container.encode(status, forKey: .status)
        try container.encode(bike_stands, forKey: .bike_stands)
        try container.encode(available_bike_stands, forKey: .available_bike_stands)
        try container.encode(available_bikes, forKey: .available_bikes)
        try container.encode(last_update, forKey: .last_update)
        try container.encode(position, forKey: .position)
    }
}
