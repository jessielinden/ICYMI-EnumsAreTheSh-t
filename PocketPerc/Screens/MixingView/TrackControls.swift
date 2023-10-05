//
//  TrackControls.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/12/23.
//

import SwiftUI

enum TrackControls: View {
    case mute(Binding<Bool>)
    case solo(Binding<Bool>)
    case pan(Binding<CGFloat>)
    case volume(Binding<Float>)
    
    var body: some View {
        switch self {
        case .mute(let isMuted):
            Button {
                isMuted.wrappedValue.toggle()
            } label: {
                Image(systemName: "speaker.slash")
            }
            .buttonStyle(.bordered)
            .foregroundColor(isMuted.wrappedValue ? .primary : .secondary)
        case .solo(let soloed):
            Button {
                soloed.wrappedValue.toggle()
            } label: {
                Text("M")
                    .hidden()
                    .overlay(
                        Text("S")
                            .fontWeight(.bold))
            }
            .buttonStyle(.bordered)
            .foregroundColor(soloed.wrappedValue ? .red : .secondary)
        case .pan(let boundValue):
            Circle()
                .frame(width: 25)
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 3, height: 15)
                        .rotationEffect(.degrees(boundValue.wrappedValue), anchor: .bottom)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    guard (-135...135).contains(value.location.x) else { return }
                                    boundValue.wrappedValue = value.location.x + value.location.y
                                }
                        )
                }
        case .volume(let value):
            Slider(value: value, in: 0...1)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        StatefulPreviewWrapper(false) {
            TrackView(track: Track.horns(.trumpet), soloed: $0)
                .padding()
        }
        
        HStack {
            StatefulPreviewWrapper(true) {
                TrackControls.mute($0)
            }
            StatefulPreviewWrapper(false) {
                TrackControls.mute($0)
            }
        }
        
        HStack {
            StatefulPreviewWrapper(true) {
                TrackControls.solo($0)
            }
            StatefulPreviewWrapper(false) {
                TrackControls.solo($0)
            }
        }
        
        HStack {
            StatefulPreviewWrapper(-45) {
                TrackControls.pan($0)
            }
            StatefulPreviewWrapper(0) {
                TrackControls.pan($0)
            }
            StatefulPreviewWrapper(45) {
                TrackControls.pan($0)
            }
        }
        
        StatefulPreviewWrapper(0.2) {
            TrackControls.volume($0)
                .accentColor(.red)
        }
        StatefulPreviewWrapper(0.35) {
            TrackControls.volume($0)
                .accentColor(.orange)
        }
        StatefulPreviewWrapper(0.55) {
            TrackControls.volume($0)
                .accentColor(.teal)
        }
        StatefulPreviewWrapper(0.75) {
            TrackControls.volume($0)
                .accentColor(.blue)
        }
        StatefulPreviewWrapper(0.9) {
            TrackControls.volume($0)
                .accentColor(.purple)
        }
    }
}
