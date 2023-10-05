//
//  PlaybackControls.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/24/23.
//

import SwiftUI

enum PlaybackControls: View {
    case playPause(Bool, () -> Void)
    case stop(() -> Void)
    case repeating(repeatMode: RepeatMode, () -> Void)
    case forward(() -> Void)
    case backward(() -> Void)
    
    private var systemName: String {
        switch self {
        case .playPause(let playbackState, _): switch playbackState {
        case true: "pause"
        case false: "play"
        }
        case .stop: "stop"
        case .repeating(let repeatMode, _): repeatMode.systemName
        case .forward: "forward"
        case .backward: "backward"
        }
    }
    
    private var isPlayPause: Bool {
        guard case .playPause = self else { return false }
        return true
    }
    
    private var repeatMode: RepeatMode? {
        guard case .repeating(let mode, _) = self else { return nil }
        return mode
    }
    
    private var action: () -> Void {
        switch self {
        case .playPause(_, let action): action
        case .stop(let action): action
        case .repeating(_, let action): action
        case .forward(let action): action
        case .backward(let action): action
        }
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "play") // maintains sizing
                .hidden()
                .overlay(
            Image(systemName: systemName)
                .imageScale(isPlayPause ? .large : .medium)
                .symbolVariant(.fill))
                .fontWeight(.bold)
        }
        .repeatModeButtonStyling(repeatMode)
    }
}

private struct RepeatModeButtonStyle: ViewModifier {
    let repeatMode: RepeatMode?
    func body(content: Content) -> some View {
        Group {
            if let repeatMode {
                if repeatMode > .none {
                    content
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.primary.opacity(0.2)))

                } else {
                    content
                        .padding(8)
                        .background(RoundedRectangle(cornerRadius: 8).fill(.clear))
                }
            } else { // non-repeat buttons
                content
                    .padding(8)
            }
        }
        .buttonStyle(.plain)
    }
}

private extension View {
    func repeatModeButtonStyling(_ repeatMode: RepeatMode?) -> some View {
        modifier(RepeatModeButtonStyle(repeatMode: repeatMode))
    }
}

#Preview {
    HStack(alignment: .top) {
        PlaybackControls.backward {}
        PlaybackControls.stop {}

        VStack {
            PlaybackControls.playPause(false) {}
            PlaybackControls.playPause(true) {}
        }
        PlaybackControls.forward {}
        
        VStack {
            PlaybackControls.repeating(repeatMode: .forever) {}
            PlaybackControls.repeating(repeatMode: .once) {}
            PlaybackControls.repeating(repeatMode: .none) {}
        }
    }
}
