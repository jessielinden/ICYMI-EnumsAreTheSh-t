//
//  Fill.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/24/23.
//

import SwiftUI

enum Fill {
    case drums(DrumFillType)
    case glock
    case guitar
    case vibraslap
    indirect case surprise(Fill)

    init?(from track: Track) {
     switch track {
        case .fill(let fill):
         switch fill {
         case .glock:
             self = Fill.glock
         case .guitar:
             self = Fill.guitar
         case .vibraslap:
             self = Fill.vibraslap
         case .drums(let fill):
             self = Fill.drums(fill)
         case .surprise(let fill):
             self = Fill.surprise(fill)
         }
        default: return nil
        }
    }
    
    public var isASurprise: Bool {
        guard case .surprise(_) = self else { return false }
        return true
    }
    
    enum DrumFillType: String, Equatable {
        case acoustic, electric
    }
}

extension Fill: SelectableContentProvider {
    static var category: Category = .fill
    static var allCases: [Fill] = [.drums(.acoustic), .drums(.electric), .glock, .guitar, .vibraslap]
    
    // Playable
    var player: AudioEnginePlayer {
        switch self {
        case .glock: AudioEngine.glock
        case .guitar: AudioEngine.guitarFill
        case .vibraslap: AudioEngine.vibraslap
        case .drums(.electric): AudioEngine.drumsElectricFill
        case .drums(.acoustic): AudioEngine.drumsAcousticFill
        case .surprise(let fill): fill.player
        }
    }
    
    var audioFileKey: String {
        let suffix = switch self {
        case .glock: "glock"
        case .guitar: "guitar"
        case .vibraslap: "vibraslap"
        case .drums(let type): "drums.\(type.rawValue)"
        case .surprise(let fill): fill.audioFileKey
        }
        return "fill.\(suffix)"
    }
}

private extension AudioEngine {
    static let glock = AudioEnginePlayer(key: Fill.glock.audioFileKey)
    static let guitarFill = AudioEnginePlayer(key: Fill.guitar.audioFileKey)
    static let vibraslap = AudioEnginePlayer(key: Fill.vibraslap.audioFileKey)
    static let drumsElectricFill = AudioEnginePlayer(key: Fill.drums(.electric).audioFileKey)
    static let drumsAcousticFill = AudioEnginePlayer(key: Fill.drums(.acoustic).audioFileKey)
}

extension Fill: RawRepresentable {
    enum Identifier: String, CaseIterable {
        case glock
        case guitar
        case vibraslap
        case drums
        case surprise
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
        case Identifier.glock.rawValue:
            self = Fill.glock
        case Identifier.guitar.rawValue:
            self = Fill.guitar
        case Identifier.vibraslap.rawValue:
            self = Fill.vibraslap
        case Identifier.drums.rawValue:
            if let fill = DrumFillType(rawValue: raw) {
                self = Fill.drums(fill)
            } else {
                return nil
            }
        case Identifier.surprise.rawValue:
            if let fill = Fill(rawValue: RawTrack(id: Fill.Identifier.surprise.rawValue + ".\(raw)")) {
                self = .surprise(fill)
            } else {
                return nil
            }
        default: return nil
        }
    }
    
    var rawValue: RawTrack {
        switch self {
        case .glock: RawTrack(id: Fill.Identifier.glock.rawValue)
        case .guitar: RawTrack(id: Fill.Identifier.guitar.rawValue)
        case .vibraslap: RawTrack(id: Fill.Identifier.vibraslap.rawValue)
        case .drums(let fill): RawTrack(id: Fill.Identifier.drums.rawValue + ".\(fill.rawValue)")
        case .surprise(let fill): RawTrack(id: Fill.Identifier.surprise.rawValue + ".\(fill.rawValue)")
        }
    }
}
