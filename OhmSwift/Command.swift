//
//  Command.swift
//  OhmSwift
//
//  Created by Corné on 2/29/24.
//

import Foundation

enum Command {
    case select(step: Int, pitch: Int)
    case deselect(step: Int, pitch: Int)
    case transaction([Command])
}
