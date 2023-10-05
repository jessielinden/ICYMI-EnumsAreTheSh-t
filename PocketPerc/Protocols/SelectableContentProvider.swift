//
//  SelectableContentProvider.swift
//  PocketPerc
//
//  Created by Jessica Linden on 6/27/23.
//

import SwiftUI

/// This protocol is used as a sort of umbrella to all the instrument types.
/// Views such as ``CategoryTagView`` and ``CategoryContainerView`` are used generically via this protocol.
protocol SelectableContentProvider: Hashable, Identifiable, Comparable, Playable, ExpressibleAsRawTrack, Toggleable {
    static var category: Category { get }
}

protocol ExpressibleAsRawTrack: RawRepresentable where Self.RawValue == RawTrack { }
protocol Toggleable: Equatable, CaseIterable where AllCases == [Self] { }

extension SelectableContentProvider {
    static var displayGroups: [[Self]] {
        let grouped = Dictionary(grouping: Self.allCases, by: \.rawValue.root)
        return grouped.values.map { $0 }
    }
    
    var category: Category {
        Self.category
    }
    
    static func asTrack(_ self: Self) -> Track {
        return switch Self.category {
        case .mallets: Track.mallets(self as! Mallets)
        case .latin: Track.latin(self as! Latin)
        case .rhythm: Track.rhythm(self as! Rhythm)
        case .horns: Track.horns(self as! Horns)
        case .fill: Track.fill(self as! Fill)
        }
    }
    
    private var defaultDisplayName: String {
        if let suffix = rawValue.suffix {
            "\(rawValue.root) \(suffix)"
        } else {
            rawValue.root
        }
    }
    
    var displayName: String {
        let instance = Self.asTrack(self)
        if case .fill(let fillType) = instance {
            return switch fillType {
            case .drums(let fill): "\(fill.rawValue) drums"
            default: "\(fillType.defaultDisplayName)"
            }
        } else if case .rhythm(let rhythm) = instance {
            return switch rhythm {
            case .keys(let keysType):
                keysType.rawValue
            case .bass(let bassType):
                "\(bassType.rawValue) bass"
            case .drums(let drumsType):
                "\(drumsType.rawValue) drums"
            default: rhythm.defaultDisplayName
            }
        } else {
        return defaultDisplayName
        }
    }
    
    var id: String { category.label + "." + rawValue.id }
        
    static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    @ViewBuilder func buttonTextView(
        isSelected: Bool,
        text suffix: String? = nil,
        action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            Text(suffix ?? displayName)
                .foregroundColor(isSelected ? .white : .secondary)
                .kerning(1.5)
        }
        .buttonStyle(.bordered)
        .background(RoundedRectangle(cornerRadius: 8).stroke(
            isSelected ? category.color : .clear, lineWidth: 3))
    }
}

