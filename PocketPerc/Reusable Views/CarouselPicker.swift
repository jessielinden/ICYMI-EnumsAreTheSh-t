//
//  CarouselPicker.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/17/23.
//

import SwiftUI

struct CarouselPicker<ContentProvider: CarouselContentProvider, Content: View>: View {
    @State private var offset: CGFloat = 0
    @GestureState private var startLocation: CGFloat?
    
    @Binding var selection: ContentProvider
    let frame: CGSize
    let content: (ContentProvider, Bool) -> Content
    
    private let allOptions: [ContentProvider] = Array(ContentProvider.allCases)
    var currentOptions: [ContentProvider] {
        [selection.previous(), selection, selection.next()].compactMap { $0 }
    }
    
    init(
        selection: Binding<ContentProvider>,
        frame: CGSize,
        content: @escaping (ContentProvider, Bool) -> Content) {
            self._selection = selection
            self.frame = frame
            self.content = content
        }
    
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                var newLocation = startLocation ?? offset
                newLocation += value.translation.width
                offset = newLocation
            }
            .onEnded { _ in
                let difference = offset - (startLocation ?? 0)
                if abs(difference) > frame.width / 2 {
                    if difference > 0 { // <=
                        withAnimation {
                            offset += frame.width - abs(difference)
                        }
                        selection.stepBackward()
                    } else { // =>
                        withAnimation {
                            offset -= frame.width - abs(difference)
                        }
                        selection.stepForward()
                    }
                    offset = 0
                } else {
                    withAnimation {
                        offset = 0
                    }
                }
            }
            .updating($startLocation) { (_, startLocation, _) in
                startLocation = startLocation ?? offset
            }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(currentOptions) { option in
                let isSelected = option == selection
                content(option, isSelected)
                    .frame(width: frame.width, height: frame.height)
                    .offset(x: offset, y: 0)
                    .disabled(selection != option)
            }
        }
        .frame(width: frame.width, height: frame.height)
        .contentShape(Rectangle())
        .gesture(dragGesture)
        .clipped()
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            SheetView()
                .environmentObject(BrowseManager())
        }
}
