//
//  Mallets.swift
//  PocketPerc
//
//  Created by Jessica Linden on 4/26/23.
//

import SwiftUI

enum Mallets: RawTrack, CaseIterable {
    case marimba
    case vibraphone = "vibes"
    
    init?(from track: Track) {
     switch track {
        case .mallets(let mallets):
            switch mallets {
            case .marimba: self = Mallets.marimba
            case .vibraphone: self = Mallets.vibraphone
            }
        default: return nil
        }
    }
}

extension Mallets: SelectableContentProvider {
    static var category: Category = .mallets
    
    // Playable
    var player: AudioEnginePlayer {
        switch self {
        case .marimba: AudioEngine.marimba
        case .vibraphone: AudioEngine.vibraphone
        }
    }
    
    var audioFileKey: String {
        switch self {
        case .marimba: "marimba"
        case .vibraphone: "vibraphone"
        }
    }
}

private extension AudioEngine {
    static let marimba = AudioEnginePlayer(key: Mallets.marimba.audioFileKey)
    static let vibraphone = AudioEnginePlayer(key: Mallets.vibraphone.audioFileKey)
}
