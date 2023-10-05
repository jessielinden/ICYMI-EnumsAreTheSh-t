//
//  PlaybackState.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/17/23.
//

import AVFoundation

enum PlaybackState<T: Numeric>: Equatable {
    case playing(T)
    case paused(T)
    
    static var stopped: Self { paused(0) }
    
    var currentPosition: T {
        return switch self {
        case .playing(let currentPosition): currentPosition
        case .paused(let currentPosition): currentPosition
        }
    }
    
    var isPlaying: Bool {
        guard case .playing(_) = self else { return false }
        return true
    }
    
    mutating func toggle() {
        switch self {
        case .playing(let currentPosition):
            self = .paused(currentPosition)
        case .paused(let currentPosition):
            self = .playing(currentPosition)
        }
    }
}

extension PlaybackState<Double> {
    init(from player: AVAudioPlayer) {
        let currentTime = player.currentTime
        switch player.isPlaying {
        case true: self = .playing(currentTime)
        case false: self = .paused(currentTime)
        }
    }
}

extension PlaybackState<AVAudioFramePosition> {
    init(isPlaying: Bool, currentPosition: AVAudioFramePosition) {
        switch (isPlaying, currentPosition) {
        case (true, let currentPosition):
            self = .playing(currentPosition)
        case (false, let currentPosition) where currentPosition == 0:
            self = .stopped
        case (false, let currentPosition):
            self = .paused(currentPosition)
        }
    }
}
