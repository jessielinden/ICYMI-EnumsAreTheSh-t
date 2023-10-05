//
//  TrackToggleView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/21/23.
//

import SwiftUI

struct TrackToggleView<ContentProvider: SelectableContentProvider>: View { // no longer using
    @Binding var track: ContentProvider?
    @StateObject var audioManager = AudioManager()

    var color: Color {
        ContentProvider.category.color
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ContentProvider.category
                Spacer()
                HStack {
                    backwardButton
                    playPauseButton
                    forwardButton
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading) {
                ForEach(Array(ContentProvider.allCases)) { item in
                    Button {
                        track = item
                    } label: {
                        Text(item.displayName)
                    }
                    .foregroundColor(track == item ? color : .secondary)
                    .buttonStyle(.bordered)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(ContentProvider.category.color, lineWidth: 3))
        .contentShape(Rectangle())
    }
}

extension TrackToggleView {
    var playPauseButton: some View {
        Button {
            if track == nil {
                track = ContentProvider.allCases.first
            }
            
          //  if let selection {
                if audioManager.player == nil {
                    audioManager.play(track: "andy") // selection.clip
                    audioManager.player?.play()
                } else {
                    audioManager.player = nil
                }
            // }
        } label: {
            PlaybackControls.playPause(isPlaying: audioManager.player?.isPlaying ?? false)
        }
    }
    
    var forwardButton: some View {
        Button {
            let wasPlaying = audioManager.player?.isPlaying
            track?.stepForward()
            if let wasPlaying {
                if wasPlaying {
                    audioManager.play(track: "andy") // selection.clip
                    audioManager.player?.play()
                }
            }
        } label: {
            PlaybackControls.forward
        }
        .disabled(track == nil)
    }
    
    var backwardButton: some View {
        Button {
            let wasPlaying = audioManager.player?.isPlaying
            track?.stepBackward()
            if let wasPlaying {
                if wasPlaying {
                    audioManager.play(track: "andy")
                    audioManager.player?.play()
                }
            }
        } label: {
            PlaybackControls.backward
        }
        .disabled(track == nil)
    }
}

private enum PlaybackControls: View {
    case playPause(isPlaying: Bool)
    case forward
    case backward
    
    var systemImage: String {
        switch self {
        case .playPause(let isPlaying): isPlaying ? "pause" : "play"
        case .forward: "forward"
        case .backward: "backward"
        }
    }
    
    var body: some View {
        Image(systemName: systemImage)
            .symbolVariant(.fill)
    }
}
    
#Preview {
        StatefulPreviewWrapper(nil) {
            TrackToggleView<Latin>(track: $0)
        }
}
