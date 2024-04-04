//
//  Event.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import Foundation

struct Event: Codable {
    let step: Double
    let pitch: Int
    var freq: Double?
    var q: Double?
}
