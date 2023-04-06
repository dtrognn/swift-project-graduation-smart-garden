//
//  Location.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import Foundation

struct Location: Codable {
    let name: String
    let country: String

    enum CodingKeys: String, CodingKey {
        case name
        case country
    }
}
