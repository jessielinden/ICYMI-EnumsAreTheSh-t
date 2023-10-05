//
//  BrowseManager.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/23/23.
//

import AVFoundation
import SwiftUI

/// Manages the ``BrowseView`` logic
class BrowseManager: ObservableObject {
    @Published var selectedTrack: (any SelectableContentProvider)? { didSet {
        let currentState = playbackState
        let currentRepeatMode = repeatMode
        
        if let selectedTrack {
           createPlayer(for: "short_" + selectedTrack.audioFileKey)
           player?.numberOfLoops = currentRepeatMode.value
        }

        guard case .playing = currentState, let player else { return }
            playbackState = .playing(0)
            update(player, from: playbackState)
    }}
    
    init() {
        selectedTrack = Category.allCases.first?.subenum.allCases.first ?? Mallets.marimba
        
        if let player {
            repeatMode = RepeatMode(from: player.numberOfLoops)
        } else {
            repeatMode = .none
        }
    }
    
    /// The category of the ``selectedTrack``.
    public var selectedCategory: Category? {
        selectedTrack?.category
    }
    
    private var player: AVAudioPlayer?
    
    private func createPlayer(for key: String) {
        guard let url = Bundle.main.url(forResource: key, withExtension: "mp3") else {
            print("Audio file \(key).mp3 not found")
            return }
            
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.prepareToPlay()
        } catch {
            print(error)
        }
    }
    
    private func update(_ player: AVAudioPlayer, from playbackState: PlaybackState<Double>) {
        switch playbackState {
        case .playing:
            player.play()
        case .stopped:
            player.stop()
            player.currentTime = 0
        case .paused:
            player.pause()
        }
    }

    public var playbackState: PlaybackState<Double> {
        get {
            if let player {
                return PlaybackState(from: player)
            } else {
                return .stopped
            }
        }
        set {
            if let player {
                update(player, from: newValue)
                self.objectWillChange.send()
            }
        }
    }
    
    @Published var repeatMode: RepeatMode { didSet {
        if let player {
            if player.numberOfLoops != repeatMode.value {
                player.numberOfLoops = repeatMode.value
            }
        }
        if playbackState != .stopped {
            mustAccountForChangedRepeatMode = true
        }
    }}
    /// A flag that is given a value if the ``repeatMode`` while playback is playing or paused and facilitates the reflection of that change in the audio via ``updatePlaybackStateIfNeeded()``.
    private var mustAccountForChangedRepeatMode: Bool?
    
    // MARK: - Playback actions
    func playPause() {
        guard let selectedTrack else {
            print("There is no selectedTrack to play in BrowseManager.")
            return }
        if player == nil {
            createPlayer(for: selectedTrack.audioFileKey)
        } else {
            playbackState.toggle()
        }
    }
    
    func stop() {
        playbackState = .stopped
    }
    
    func forward() {
        if let selectedTrack, let selectedCategory {
            if selectedTrack.id == selectedCategory.subenum.allCases.last?.id {
                guard let nextCategory = selectedCategory.next() else { return }
                self.selectedTrack = nextCategory.subenum.allCases.first
            } else {
                guard let nextTrack = selectedTrack.next() else { return }
                self.selectedTrack = nextTrack
            }
        }
    }
    
    func backward() {
        if let selectedTrack, let selectedCategory {
            if selectedTrack.id == selectedCategory.subenum.allCases.first?.id {
                guard let previousCategory = selectedCategory.previous() else { return }
                self.selectedTrack = previousCategory.subenum.allCases.last
            } else {
                guard let previousTrack = selectedTrack.previous() else { return }
                self.selectedTrack = previousTrack
            }
        }
    }
    
    // MARK: - Updating playbackState and repeatMode if needed
    /// If the audio has finished playing, the ``playbackState`` and ``repeatMode`` are reset.
    public func updatePlaybackStateIfNeeded() {
        
        func reset() {
            let previousPlaybackState = playbackState
            playbackState = .stopped
            mustAccountForChangedRepeatMode = nil
            playbackState = previousPlaybackState
        }
        
        if let player {
            if player.currentTime >= (player.duration * 0.99) { // practical completion, possibly not 100% accurate
                switch repeatMode {
                case .times(let total, let progress):
                    if total == progress {
                        playbackState = .stopped
                        repeatMode = .times(total, progress: 0)
                    } else {
                        if mustAccountForChangedRepeatMode != nil {
                            repeatMode = .times(total, progress: progress + 1)
                            reset()
                        }
                    }
                case .forever:
                    if mustAccountForChangedRepeatMode != nil {
                        reset()
                    }
                }
            }
        }
    }
}

extension Category {
    var subenum: any SelectableContentProvider.Type {
        switch self {
        case .mallets: Mallets.self
        case .latin: Latin.self
        case .horns: Horns.self
        case .rhythm: Rhythm.self
        case .fill: Fill.self
        }
    }
}
