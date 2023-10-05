//
//  Horns.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/29/23.
//

import Foundation

enum Horns: RawTrack {
    case section = "horn section"
    case trumpet
    
    init?(from track: Track) {
     switch track {
        case .horns(let horns):
            switch horns {
            case .section: self = Horns.section
            case .trumpet: self = Horns.trumpet
            }
        default: return nil
        }
    }
}

extension Horns: SelectableContentProvider {
    static var category: Category = .horns
    
    // Playable
    var player: AudioEnginePlayer {
        switch self {
        case .section: AudioEngine.hornSection
        case .trumpet: AudioEngine.trumpet
        }
    }
    
    var audioFileKey: String {
        switch self {
        case .section: "horns"
        case .trumpet: "trumpet"
        }
    }
}

private extension AudioEngine {
    static let hornSection = AudioEnginePlayer(key: "horns")
    static let trumpet = AudioEnginePlayer(key: "trumpet")
}
