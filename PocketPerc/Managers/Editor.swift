//
//  Editor.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/23/23.
//

import AVFoundation

class Editor: ObservableObject {
    @Published var mix: Mix
    
    init(originalMix: Mix) {
        self.mix = originalMix
      //  singleTrackPlayer.isMuted = true
    }
    
    var playbackState: SingleTrackPlayer.PlaybackState {
        get {
            singleTrackPlayer.playbackState
        }
        set {
            singleTrackPlayer.playbackState = newValue
            mix.tracks.forEach { track in
              //  track.SingleTrackPlayer.playbackState = newValue
            }
            self.objectWillChange.send()
        }
    }
    
    var repeatMode: RepeatMode {
        get {
            singleTrackPlayer.repeatMode
        }
        set {
            singleTrackPlayer.repeatMode = newValue
            mix.tracks.forEach { track in
               // track.SingleTrackPlayer.repeatMode = newValue
            }
            self.objectWillChange.send()
        }
    }
    
    let singleTrackPlayer: SingleTrackPlayer = SingleTrackPlayer(key: "marimba") // eventually guide track or phantom
    private var players: [AVAudioPlayer] {
      //  let players = Array(mix.tracks).compactMap { $0.SingleTrackPlayer.player }
        return []
    }
    private var player: AVAudioPlayer? {
        singleTrackPlayer.player
    }
}
