//
//  SingleTrackPlayer.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/10/23.
//

import AVFoundation

final class SingleTrackPlayer: ObservableObject {
    @Published var player: AVAudioPlayer?
    
    init(key: String) {
        //  createPlayer(with: key)
    }
    
    init(){}

}

