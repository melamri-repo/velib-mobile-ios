//
//  PositionModel.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit

struct PositionModel: Codable {
    let position_x: Double?
    let position_y: Double?
    /// CodingKeys
    enum CodingKeys: String, CodingKey {
        case position_x
        case position_y
    }
    /// init from decoder
    ///
    /// - Parameter decoder: Decoder
    /// - Throws: error
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        position_x = try values.decodeIfPresent(Double.self, forKey: .position_x)
        position_y = try values.decodeIfPresent(Double.self, forKey: .position_y)
    }
    /// Encode
    ///
    /// - Parameter encoder: Encoder
    /// - Throws: error
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(position_x, forKey: .position_x)
        try container.encode(position_y, forKey: .position_y)
    }
}
