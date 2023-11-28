//
//  SoloMode.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/11/23.
//

import SwiftUI

enum SoloMode {
    case off(Set<Track> = [])
    case on(Set<Track> = [])
    
    var tracks: Set<Track> {
        get {
            switch self {
            case .off(let tracks): tracks
            case .on(let tracks): tracks
            }
        }
        set {
            switch self {
            case .on: self = .on(newValue)
            case .off: self = .off(newValue)
            }
        }
    }
    
    var isOn: Bool {
        guard case .on(_) = self else { return false }
        return true
    }
    
    mutating func toggle() {
        switch self {
        case .off(let tracks): self = .on(tracks)
        case .on(let tracks): self = .off(tracks)
        }
    }
    
    mutating func remove(_ track: Track) {
       tracks.remove(track)
    }
    
    mutating func insert(_ track: Track) {
       tracks.insert(track)
    }
}

/// Used in ``TrackView`` to determine mute button functionality.
private struct SoloModeEnvironmentKey: EnvironmentKey {
    static var defaultValue: SoloMode = .off()
}

extension EnvironmentValues {
    var soloMode: SoloMode {
        get {
            return self[SoloModeEnvironmentKey.self]
        }
        
        set {
            self[SoloModeEnvironmentKey.self] = newValue
        }
    }
}
