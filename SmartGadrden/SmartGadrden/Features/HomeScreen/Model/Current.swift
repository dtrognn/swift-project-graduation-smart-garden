//
//  Current.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import Foundation

struct Current: Codable {
    let tempC: Float
    let windKph: Float

    enum CodingKeys: String, CodingKey {
        case tempC = "temp_c"
        case windKph = "wind_kph"
    }
}
