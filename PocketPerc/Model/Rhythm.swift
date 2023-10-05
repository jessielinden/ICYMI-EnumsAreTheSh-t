//
//  Rhythm.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/24/23.
//

import Foundation

enum Rhythm {
    case guitar
    case keys(KeysType)
    case bass(BassType)
    case drums(DrumsType)
   
    init?(from track: Track) {
     switch track {
        case .rhythm(let rhythm):
         switch rhythm {
         case .guitar:
             self = Rhythm.guitar
         case .keys(let type):
             self = Rhythm.keys(type)
         case .bass(let type):
             self = Rhythm.bass(type)
         case .drums(let type):
             self = Rhythm.drums(type)
         }
        default: return nil
        }
    }
    
    enum KeysType: String {
        case EP
        case piano
        case wurlitzer = "wurlie"
    }
    
    enum BassType: String {
        case electric
        case synth
    }
    
    enum DrumsType: String {
        case acoustic
        case club
    }
    
    static func <(lhs: Rhythm, rhs: Rhythm) -> Bool { // custom implementation overrides raw value (used in QuickSelect)
        let lhsIndex = allCases.firstIndex(of: lhs)
        let rhsIndex = allCases.firstIndex(of: rhs)
        if let lhsIndex, let rhsIndex {
            return lhsIndex < rhsIndex
        } else {
            return false
        }
    }
     
}

extension Rhythm: SelectableContentProvider {
    static var category: Category = .rhythm
    
    static var allCases: [Rhythm] = [.guitar, .keys(.EP), .keys(.piano), .keys(.wurlitzer), .bass(.electric), .bass(.synth), .drums(.acoustic), .drums(.club)]
    
    // Playable
    var player: AudioEnginePlayer {
        switch self {
        case .guitar: AudioEngine.guitar
        case .keys(.EP): AudioEngine.keysEP
        case .keys(.piano): AudioEngine.keysPiano
        case .keys(.wurlitzer): AudioEngine.keysWurlitzer
        case .bass(.electric): AudioEngine.bassElectric
        case .bass(.synth): AudioEngine.bassSynth
        case .drums(.acoustic): AudioEngine.drumsAcoustic
        case .drums(.club): AudioEngine.drumsClub
        }
    }
    
    var audioFileKey: String {
        switch self {
        case .guitar: "guitar"
        case .keys(let type): "keys.\(type.rawValue)"
        case .bass(let type): "bass.\(type.rawValue)"
        case .drums(let type): "drums.\(type.rawValue)"
        }
    }
}

private extension AudioEngine {
    static let keysEP = AudioEnginePlayer(key: Rhythm.keys(.EP).audioFileKey)
    static let keysPiano = AudioEnginePlayer(key: Rhythm.keys(.piano).audioFileKey)
    static let keysWurlitzer = AudioEnginePlayer(key: Rhythm.keys(.wurlitzer).audioFileKey)
    static let bassElectric = AudioEnginePlayer(key: Rhythm.bass(.electric).audioFileKey)
    static let bassSynth = AudioEnginePlayer(key: Rhythm.bass(.synth).audioFileKey)
    static let guitar = AudioEnginePlayer(key: Rhythm.guitar.audioFileKey)
    static let drumsAcoustic = AudioEnginePlayer(key: Rhythm.drums(.acoustic).audioFileKey)
    static let drumsClub = AudioEnginePlayer(key: Rhythm.drums(.club).audioFileKey)
}

extension Rhythm: RawRepresentable {
    enum Identifier: String, CaseIterable {
        case guitar
        case keys
        case bass
        case drums
    }
    
    init?(rawValue: RawTrack) {
        let string = rawValue.id
        let identifierMatches = Identifier.allCases.map(\.rawValue).filter { string.contains($0) }
        guard
            identifierMatches.count == 1,
            let match = identifierMatches.first
        else {
            return nil
        }
        
        let raw = string.replacingOccurrences(of: (match + "."), with: "")
        
        switch match {
        case Identifier.guitar.rawValue:
            self = Rhythm.guitar
        case Identifier.keys.rawValue:
            if let type = KeysType(rawValue: raw) {
                self = Rhythm.keys(type)
            } else {
                return nil
            }
        case Identifier.bass.rawValue:
            if let type = BassType(rawValue: raw) {
                self = Rhythm.bass(type)
            } else {
                return nil
            }
        case Identifier.drums.rawValue:
            if let type = DrumsType(rawValue: raw) {
                self = Rhythm.drums(type)
            } else {
                return nil
            }
        default: return nil
        }
    }
    
    var rawValue: RawTrack {
        switch self {
        case .guitar: RawTrack(id: Rhythm.Identifier.guitar.rawValue)
        case .keys(let type): RawTrack(id: Rhythm.Identifier.keys.rawValue + ".\(type.rawValue)")
        case .bass(let type): RawTrack(id: Rhythm.Identifier.bass.rawValue + ".\(type.rawValue)")
        case .drums(let type): RawTrack(id: Rhythm.Identifier.drums.rawValue + ".\(type.rawValue)")
        }
    }
}
