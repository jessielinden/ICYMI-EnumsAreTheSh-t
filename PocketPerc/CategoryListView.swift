//
//  CategoryListView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/23/23.
//

import SwiftUI

struct CategoryListView: View {
    @EnvironmentObject var mixer: Mixer
    @State private var mode: Mode = .batchEdit
    
    enum Mode: Identifiable, CaseIterable {
        case batchEdit, browse
        
        var id: Self { self }
        var textLabel: String {
            switch self {
            case .batchEdit: "Batch Edit"
            case .browse: "Browse"
            }
        }
        
        var systemImage: String {
            switch self {
            case .batchEdit: "pencil"
            case .browse: "eyes"
            }
        }
        
        var label: some View {
            Label(textLabel, systemImage: systemImage)
                .font(.title3)
        }
        
        var subtitle: String {
            switch self {
            case .browse: "Explore the catalog without impacting your mix."
            case .batchEdit: "Consider changes to your mix."
            }
        }
        
        mutating func toggle() {
            switch self {
            case .browse: self = .batchEdit
            case .batchEdit: self = .browse
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 8) {
                HStack { // maybe edit ScreenHeaderView later to allow for a second set of info
                    Mode.batchEdit.label
                        .foregroundColor(mode == .batchEdit ? .primary : .secondary)
                    Rectangle().frame(width: 1)
                    Mode.browse.label
                        .foregroundColor(mode == .browse ? .primary : .secondary)
                }
                Text(mode.subtitle)
            }
            .fixedSize(horizontal: false, vertical: true)
            .onTapGesture {
                withAnimation {
                    mode.toggle()
                }
            }
        }
    }
}

#Preview {
    CategoryListView()
        .environmentObject(Mixer())
}
