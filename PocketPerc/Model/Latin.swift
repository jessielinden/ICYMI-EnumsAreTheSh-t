//
//  Latin.swift
//  PocketPerc
//
//  Created by Jessica Linden on 4/26/23.
//

import SwiftUI

enum Latin: CaseIterable {
    case agogo
    case bongos
    case cabasa
    case clave(ClaveConfig)
    case cowbell
    case guiro
    case shaker
    case triangle
    
    init?(from track: Track) {
     switch track {
        case .latin(let latin):
            switch latin {
            case .agogo: self = Latin.agogo
            case .bongos: self = Latin.bongos
            case .cabasa: self = Latin.cabasa
            case .clave(let config): self = Latin.clave(config)
            case .cowbell: self = Latin.cowbell
            case .guiro: self = Latin.guiro
            case .shaker: self = Latin.shaker
            case .triangle: self = Latin.triangle
            }
        default: return nil
        }
    }
    
    enum ClaveConfig: String {
        case threeTwo = "3-2"
        case twoThree = "2-3"
        
        var root: String {
            rawValue
        }
    }
}

extension Latin: SelectableContentProvider {
    static var category: Category = .latin
    
    static var allCases: [Latin] {
        [.agogo, .bongos, .cabasa, .clave(.twoThree), .clave(.threeTwo), .cowbell, .guiro, .shaker, .triangle]
    }
    
    // Playable
    var player: AudioEnginePlayer {
        switch self {
        case .agogo: AudioEngine.agogo
        case .bongos: AudioEngine.bongos
        case .cabasa: AudioEngine.cabasa
        case .clave(let config): config == .threeTwo ? AudioEngine.claveThreeTwo : AudioEngine.claveTwoThree
        case .cowbell: AudioEngine.cowbell
        case .guiro: AudioEngine.guiro
        case .shaker: AudioEngine.shaker
        case .triangle: AudioEngine.triangle
        }
    }
    
    var audioFileKey: String {
        switch self {
        case .agogo: "agogo"
        case .bongos: "bongos"
        case .cabasa: "cabasa"
        case .clave(let config): "clave.\(config.rawValue)"
        case .cowbell: "cowbell"
        case .guiro: "guiro"
        case .shaker: "shaker"
        case .triangle: "triangle"
        }
    }
}

private extension AudioEngine {
    static let agogo = AudioEnginePlayer(key: Latin.agogo.audioFileKey)
    static let bongos = AudioEnginePlayer(key: Latin.bongos.audioFileKey)
    static let cabasa = AudioEnginePlayer(key: Latin.cabasa.audioFileKey)
    static let claveThreeTwo = AudioEnginePlayer(key: Latin.clave(.threeTwo).audioFileKey)
    static let claveTwoThree = AudioEnginePlayer(key: Latin.clave(.twoThree).audioFileKey)
    static let cowbell = AudioEnginePlayer(key: Latin.cowbell.audioFileKey)
    static let guiro = AudioEnginePlayer(key: Latin.guiro.audioFileKey)
    static let shaker = AudioEnginePlayer(key: Latin.shaker.audioFileKey)
    static let triangle = AudioEnginePlayer(key: Latin.triangle.audioFileKey)
}

extension Latin: RawRepresentable {
    enum Identifier: String, CaseIterable {
        case agogo
        case bongos
        case cabasa
        case clave
        case cowbell
        case guiro
        case shaker
        case triangle
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
        case Identifier.agogo.rawValue:
            self = Latin.agogo
        case Identifier.bongos.rawValue:
            self = Latin.bongos
        case Identifier.cabasa.rawValue:
            self = Latin.cabasa
        case Identifier.cowbell.rawValue:
            self = Latin.cowbell
        case Identifier.guiro.rawValue:
            self = Latin.guiro
        case Identifier.shaker.rawValue:
            self = Latin.shaker
        case Identifier.triangle.rawValue:
            self = Latin.triangle
        case Identifier.clave
                .rawValue:
            guard let config = ClaveConfig(rawValue: raw) else { return nil }
            self = Latin.clave(config)
        default: return nil
        }
    }
    
    var rawValue: RawTrack {
        switch self {
        case .agogo: RawTrack(id: Latin.Identifier.agogo.rawValue)
        case .bongos: RawTrack(id: Latin.Identifier.bongos.rawValue)
        case .cabasa: RawTrack(id: Latin.Identifier.cabasa.rawValue)
        case .cowbell: RawTrack(id: Latin.Identifier.cowbell.rawValue)
        case .guiro: RawTrack(id: Latin.Identifier.guiro.rawValue)
        case .shaker: RawTrack(id: Latin.Identifier.shaker.rawValue)
        case .triangle: RawTrack(id: Latin.Identifier.triangle.rawValue)
        case .clave(let config): RawTrack(id: Latin.Identifier.clave.rawValue + ".\(config.rawValue)")
        }
    }
}


