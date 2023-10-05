//
//  Category.swift
//  PocketPerc
//
//  Created by Jessica Linden on 6/28/23.
//

import SwiftUI

enum Category: Int, CarouselContentProvider, Comparable {
    case mallets
    case latin
    case horns
    case rhythm
    case fill
    
    var id: Self { self }
    
    var label: String {
        switch self {
        case .mallets: "mallets"
        case .latin: "latin"
        case .horns: "horns"
        case .rhythm: "rhythm section"
        case .fill: "fill"
        }
    }
    
    var color: Color {
        switch self {
        case .mallets: .pink
        case .latin: .orange
        case .horns: .teal
        case .rhythm: .blue
        case .fill: .indigo
        }
    }
    
    static func <(lhs: Category, rhs: Category) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
    
    var header: some View {
        Label(label.uppercased(), systemImage: "music.note")
    }
}

protocol CarouselContentProvider: Identifiable, Toggleable { }

