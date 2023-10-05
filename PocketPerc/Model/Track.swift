//
//  Track.swift
//  PocketPerc
//
//  Created by Jessica Linden on 4/26/23.
//

import AVFoundation
import SwiftUI

/// Serves as a wrapper around each instrument type in order to hold a group of them in a collection, i.e. ``Mix``.
enum Track: Hashable, Identifiable, Comparable, CaseIterable {
    case mallets(Mallets)
    case latin(Latin)
    case horns(Horns)
    case rhythm(Rhythm)
    case fill(Fill)
    
    static let allCases: [Track] =
        Mallets.allCases.map { .mallets($0) } +
        Latin.allCases.map { .latin($0) } +
        Horns.allCases.map { .horns($0) } +
        Rhythm.allCases.map { .rhythm($0) } +
        Fill.allCases.map { .fill($0) }
    
    var id: String { wrappedValue.id }
    
    public var displayName: String {
        if case .fill(let fillType) = self {
            return switch fillType {
            case .surprise: "surprise"
            case .guitar: "\(fillType) (fill)"
            case .drums(let fill): "\(fill.rawValue) drums (fill)"
            default: "\(fillType)"
            }
        } else if case .rhythm(let rhythm) = self {
            return switch rhythm {
            case .keys(let keysType):
                keysType.rawValue
            case .bass(let bassType):
                "\(bassType.rawValue) bass"
            case .drums(let drumsType):
                "\(drumsType.rawValue) drums"
            default: rhythm.displayName
            }
        } else {
            return wrappedValue.displayName
        }
    }
    
    public var color: Color {
        category.color
    }
    
    public var category: Category {
        switch self {
        case .mallets: .mallets
        case .latin: .latin
        case .rhythm: .rhythm
        case .horns: .horns
        case .fill: .fill
        }
    }
    
    public var player: AudioEnginePlayer {
        wrappedValue.player
    }
    
    private var wrappedValue: any SelectableContentProvider {
        switch self {
        case .mallets(let mallets): mallets
        case .latin(let latin): latin
        case .rhythm(let rhythm): rhythm
        case .horns(let horns): horns
        case .fill(let fill): fill
        }
    }
}

