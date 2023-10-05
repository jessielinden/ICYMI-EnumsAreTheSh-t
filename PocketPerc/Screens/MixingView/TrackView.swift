//
//  TrackView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/19/23.
//

import SwiftUI

struct TrackView: View {
    @ObservedObject var track: AudioEnginePlayer
    @Binding var soloed: Bool
    let trackName: String
    let color: Color

    init(track: Track, soloed: Binding<Bool>) {
        self.track = track.player
        self._soloed = soloed
        self.trackName = track.displayName
        self.color = track.category.color
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(trackName)
                .kerning(1.3)
                .foregroundColor(track.isMuted ? .secondary : .primary)

            HStack {
                TrackControls.mute($track.isMuted)
                
                TrackControls.solo($soloed)

                TrackControls.pan($track.scaledPan)
                    .opacity(track.isMuted ? 0.5 : 1)

                TrackControls.volume($track.sliderVolume)
                    .opacity(track.isMuted ? 0.5 : 1)
                    .accentColor(color)
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).stroke(color, lineWidth: 3))
    }
}

#Preview {
    VStack(spacing: 20) {
        StatefulPreviewWrapper(false) {
            TrackView(track: Track.latin(.shaker), soloed: $0)
        }
        StatefulPreviewWrapper(false) {
            TrackView(track: Track.fill(.guitar), soloed: $0)
        }
    }
}
