//
//  SheetView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/14/23.
//

import SwiftUI

struct SheetView: View {
    @ObservedObject var mixer: Mixer
    @State private var sheetState: SheetState = .quickSelect
    var body: some View {
        ZStack {
            BrowseView(pauseIfNeeded: { mixer.pauseIfNeeded() })
            
            if sheetState == .quickSelect {
                QuickSelectView(selection: $mixer.quickSelectCategorySelection, mix: $mixer.mix)
                    .background()
            }
        }
        .padding(.vertical)
        .ignoresSafeArea()
        .presentationDetents([.medium, .large], selection: $sheetState.detent)
    }
}

enum SheetState {
    case quickSelect, browse
    
    var id: Self { self }
    var textLabel: String {
        switch self {
        case .quickSelect: "Quick Select"
        case .browse: "Browse"
        }
    }
    
    var icon: String {
        switch self {
        case .quickSelect: "plus.square.fill.on.square.fill"
        case .browse: "ear"
        }
    }
    
    var subtitle: String {
        switch self {
        case .quickSelect: "Tap to quickly add or remove a track to your mix."
        case .browse: "Explore the catalog."
        }
    }
    
    var header: some View {
        VStack(spacing: 8) {
            Label(textLabel, systemImage: icon)
                .font(.title3)
            Text(subtitle)
                .font(.caption)
        }
        .multilineTextAlignment(.center)
    }
    
    var detent: PresentationDetent {
        get {
            switch self {
            case .quickSelect: .medium
            case .browse: .large
            }
        }
        set {
            switch newValue {
            case .medium: self = .quickSelect
            case .large: self = .browse
            default: break
            }
        }
    }
}

struct Dismissable: ViewModifier {
    @Environment(\.dismiss) var dismiss
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .foregroundColor(.primary)
                        .padding(.trailing)
                }
            }
    }
}

extension View {
    func dismissable() -> some View {
        modifier(Dismissable())
    }
}

#if DEBUG
extension SheetView {
    init(mixer: Mixer = Mixer(), sheetState: SheetState = .quickSelect) {
        self._mixer = ObservedObject(wrappedValue: mixer)
        self._sheetState = State(wrappedValue: sheetState)
    }
}
#endif

#Preview("Quick Select") {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            SheetView()
                .environmentObject(BrowseManager())
        }
}

#Preview("Browse") {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            SheetView(sheetState: .browse)
                .environmentObject(BrowseManager())
        }
}
