//
//  OscManager.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import Foundation
import OSCKit

final class OscManager {
    private let oscClient = OSCClient()
    
    private let host = "192.168.2.6"
//    private let host = "127.0.0.1"
    private let port: UInt16 = 11000
    
    func start() throws {
        try oscClient.start()
    }
    
    func set(frequency: Double) {
        try! oscClient.send(
            .message("/frequency", values: [frequency]),
            to: host,
            port: port)
    }
    
    func set(resonance: Double) {
        try! oscClient.send(
            .message("/resonance", values: [resonance]),
            to: host,
            port: port)
    }
}
