//
//  QuickSelectView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 6/27/23.
//

import SwiftUI

struct QuickSelectView: View {
    @Binding var selection: Category
    @Binding var mix: Mix
    var body: some View {
        VStack {
            SheetState.quickSelect.header
            
            GeometryReader { geo in
                CarouselPicker(selection: $selection, frame: geo.size) { (selection, _) in
                    VStack {
                        Group {
                            switch selection {
                            case .mallets: CategoryContainerView(selections: $mix.selectedMallets)
                            case .latin: CategoryContainerView(selections: $mix.selectedLatin)
                            case .rhythm: CategoryContainerView(selections: $mix.selectedRhythmSection)
                            case .horns: CategoryContainerView(selections: $mix.selectedHorns)
                            case .fill: CategoryContainerView(selections: $mix.selectedFills) {
                                SurpriseButton(isSelected: surpriseIsSelected())
                            }
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.horizontal)
                    .padding(.top)
                }
            }
            
            CarouselIndicator(selection: selection.rawValue)
        }
        .dismissable()
    }
    
    func surpriseIsSelected() -> Binding<Bool> {
        Binding(
            get: { mix.selectedFills.contains(where: { $0.isASurprise })},
            set: { shouldBeSelected in
                if !shouldBeSelected {
                    self.mix.selectedFills = []
                } else {
                    let surprise = Fill.allCases.randomElement()
                    if let surprise {
                        self.mix.selectedFills = [.surprise(surprise)]
                    }
                }
            }
        )
    }
}

struct SurpriseButton: View {
    @Binding var isSelected: Bool
    var body: some View {
        Button {
            isSelected.toggle()
        } label: {
            Image(systemName: "gift")
                .symbolVariant(isSelected ? .fill : .none)
        }
        .buttonStyle(.bordered)
        .background(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? .indigo : .clear, lineWidth: 3))
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            StatefulPreviewWrapper(Category.fill) { selection in
                StatefulPreviewWrapper(Mix.empty) { mix in
                    QuickSelectView(selection: selection, mix: mix)
                        .padding(.top)
                }
            }
            .presentationDetents([.medium])
        }
}
