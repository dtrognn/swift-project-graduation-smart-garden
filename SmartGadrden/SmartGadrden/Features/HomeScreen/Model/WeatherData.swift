//
//  WeatherData.swift
//  SmartGarden
//
//  Created by Vu Duc Trong on 27/03/2023.
//

import Foundation

struct WeatherData: Codable {
    let location: Location
    let current: Current
}
