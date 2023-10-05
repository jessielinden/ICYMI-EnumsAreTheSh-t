//
//  SheetView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/14/23.
//

import SwiftUI

enum SheetState {
  static let quickSelect = PresentationDetent.medium
  static let listen = PresentationDetent.large
}

struct SheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var sheetState: PresentationDetent
    @State private var selection: Category
    @EnvironmentObject var mixer: Mixer
    
    init(
        sheetState: PresentationDetent = SheetState.quickSelect,
        selection: Category = .mallets) {
        self._sheetState = State(wrappedValue: sheetState)
        self._selection = State(wrappedValue: selection)
    }
                
    var body: some View {
        VStack {
            VStack {
                if sheetState == SheetState.quickSelect {
                    Label("Quick Select", systemImage: "plus.square.fill.on.square.fill")
                        .font(.title3)
                    Group {
                        Text("Tap to quickly add or remove a track to your mix.")
                        Text("Swipe to browse categories.")
                    }
                    .font(.caption)
                    
                    GeometryReader { geo in
                        CarouselPicker(selection: $selection, frame: geo.size) { (option, _) in
                            VStack {
                                Group {
                                    switch option {
                                    case .mallets:  QuickSelectView(selections: $mixer.mix.selectedMallets)
                                    case .latin:
                                        QuickSelectView(selections: $mixer.mix.selectedLatin)
                                    case .electronic: Text("electronic")
                                    }
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                            .padding(.top)
                        }
                    }
                } else {
                    ListenView()
                }
            }
            .padding([.horizontal, .top])
        }
        .ignoresSafeArea()
        .overlay(alignment: .topTrailing) {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .padding()
        }
        .presentationDetents([.medium, .large], selection: $sheetState)
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            SheetView()
                .environmentObject(Mixer())
        }
}
