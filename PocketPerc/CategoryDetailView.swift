//
//  CategoryDetailView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/21/23.
//

import SwiftUI

struct CategoryDetailView<ContentProvider: SelectableContentProvider>: View { // no longer using
    @State private var selection: ContentProvider?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            TrackToggleView(track: $selection)
            
            if let selection {
                VStack {
                    Image(selection.imageResource)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 5)
                        .grayscale(1)
//                        .animation(.default, value: selection)
//                        .transition(.move(edge: .bottom))
                    
                    Text("""
This is some placeholder text for \(selection.displayName) information.
""")
                    .multilineTextAlignment(.center)
                    
                    Button {
                        
                    } label: {
                        Text("Add \(selection.displayName) to mix")
                    }
                    .buttonStyle(.borderedProminent)
                    .accentColor(.green)
                }
            }
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            StatefulPreviewWrapper(Mix.sample) {
                SheetView(mix: $0, sheetState: SheetState.listen)
            }
        }
}
