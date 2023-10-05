//
//  AudioEngine.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/11/23.
//

import AVFoundation

/// [AVAudioEngine Tutorial](https://www.kodeco.com/21672160-avaudioengine-tutorial-for-ios-getting-started?page=1#toc-anchor-001)

/// Provides an `AVAudioEngine` to the ``Mixer``.
class AudioEngine {
    let engine = AVAudioEngine()
    static let click = AudioEnginePlayer(key: "click")
    let players: [AudioEnginePlayer]
    
    init() {
        let mixerNode = engine.mainMixerNode
        engine.prepare()
        
        var players = Track.allCases.map { $0.player }
        players.append(Self.click)
        self.players = players
        
        players.forEach {
            engine.attach($0.node)
            engine.connect($0.node, to: mixerNode, format: nil)
        }
        
        do {
            try engine.start()
        } catch {
            print("Error starting the audio engine: \(error)")
        }
    }
}
