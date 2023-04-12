//
//  TimeInterval+Format.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 12/04/2023.
//

import Foundation

extension TimeInterval {
    var time: String {
        return String(format: "%02d:%02d:%02d",
                      Int(self / 3600),
                      Int((self / 60).truncatingRemainder(dividingBy: 60)),
                      Int(truncatingRemainder(dividingBy: 60)))
    }
}
