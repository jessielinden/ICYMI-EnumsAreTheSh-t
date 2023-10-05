//
//  RepeatMode.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/2/23.
//

import Foundation

enum RepeatMode: Equatable, CaseIterable, Comparable {
    case times(_ total: Int, progress: Int = 0)
    case forever
    
    static var none: Self { .times(0) }
    static var once: Self { .times(1) }
    
    static var allCases: [RepeatMode] = [.none, .forever, .once]
    
    init(from playerValue: Int) {
        switch playerValue {
        case -1: self = .forever
        default: self = .times(playerValue)
        }
    }
    
    var systemName: String {
        switch self {
        case .times(let times, _) where times == 1: "repeat.1"
        default: "repeat"
        }
    }
    
    var value: Int {
        switch self {
        case .none: 0
        case .once: 1
        case .times(let times, _): times
        case .forever: -1
        }
    }
    
    mutating func toggle() {
        self.stepForward()
    }
}
