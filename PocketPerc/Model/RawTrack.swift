//
//  RawTrack.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/22/23.
//

import Foundation

/// Backs the instruments as their raw type. Contains foundational string information.
struct RawTrack: Equatable, Identifiable, Comparable, Hashable {
    let id: String
    let root: String
    let suffix: String?
    
    static func <(lhs: RawTrack, rhs: RawTrack) -> Bool {
        lhs.id < rhs.id
    }
}

extension RawTrack: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        self.init(id: value)
    }
    
    init(id: String) {
        let components = id.components(separatedBy: ".")
        self.id = id
        root = components[0]
        suffix = components.count == 2 && id.contains(".") ? components[1] : nil
    }
}

