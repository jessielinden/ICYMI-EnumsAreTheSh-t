//
//  Mixer.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/18/23.
//

import AVFoundation

/// Facilitates the audio playback of a ``Mix`` via the ``AudioEngine``.
class Mixer: ObservableObject {
    @Published var mix: Mix { didSet {
        mix.tracks.forEach {
            if !oldValue.tracks.contains($0) {
                $0.player.scheduleAudio(at: currentPosition)
                $0.player.update(from: playbackState)
                $0.player.isMuted = false
            }
        }
        
        oldValue.tracks.forEach {
            if !mix.tracks.contains($0) {
                $0.player.node.stop()
            }
        }
    }}
    @Published var quickSelectCategorySelection: Category = .mallets
    @Published var repeatMode: RepeatMode = .none
    
    /// Updated when scrubbing the ``SeekBar``.
    @Published var scrubbing = false {
        didSet {
            if scrubbing {
                displayLink?.isPaused = true
            } else {
                switch playbackState {
                case .playing:
                    playbackState = .paused(currentPosition) // rescheduling
                    playbackState = .playing(currentPosition) // resuming playback
                case .paused:
                    playbackState = .paused(currentPosition)
                }
            }
        }
    }
    
    @Published var soloMode: SoloMode = .off() {
        didSet {
            switch soloMode {
            case .on(let tracks): mix.tracks.forEach {
                $0.player.updateWasMutedWhenSoloModeWasTurnedOn()
                if !tracks.contains($0) {
                    $0.player.isMuted = true
                }
            }
            case .off: mix.tracks.forEach {
                if let wasPreviouslyMuted = $0.player.wasMutedWhenSoloModeWasTurnedOn {
                    $0.player.isMuted = wasPreviouslyMuted
                    $0.player.wasMutedWhenSoloModeWasTurnedOn = nil
                }
            }
            }
        }
    }
    public var isInSoloMode: Bool {
        get {
            guard case .on(_) = soloMode else { return false }
            return true
        }
        set {
            soloMode.toggle()
        }
    }
    
    private var displayLink: CADisplayLink?
    private let audioEngine = AudioEngine()
    
    /// A silent click track used to keep the other tracks in sync.
    private let click = AudioEngine.click
    
    /// Audio duration.
    public let maxTime: Double
    
    /// The players for the tracks in the ``mix``.
    private var selectedPlayers: [AudioEnginePlayer] {
        var selectedPlayers = mix.tracks.map { $0.player }
        selectedPlayers.insert(click, at: 0)
        return selectedPlayers
    }
    
    init(mix: Mix = .empty) {
        self.mix = mix
        
        if let file = click.file {
            maxTime = Double(file.length) / file.processingFormat.sampleRate
        } else {
            maxTime = 0
        }
        
        selectedPlayers.forEach { player in
            player.scheduleAudio()
            player.isMuted = false
        }
        click.isMuted = true
        setupDisplayLink()
    }
    
    /// The frame position from which the audio should be playing. This property is the glue that holds this entire class together.
    @Published var currentPosition: AVAudioFramePosition = 0
    
    /// Used to update the ``currentPosition``. Can be thought of as an offset value that gets added to the ``currentFrame``.
    var seekFrame: AVAudioFramePosition = 0
    
    /// Link between the ``currentPosition`` and ``SeekBar``.
    public var seekTime: Double {
        get {
            guard let file = click.file else { return 0 }
            return Double(currentPosition) / file.processingFormat.sampleRate
        }
        set {
            guard let file = click.file else { return }
            let newPosition = AVAudioFramePosition(newValue * file.processingFormat.sampleRate)
            currentPosition = min(max(newPosition, 0), file.length - 1) // stops crash in scheduleSegment when scrubbed to the max
        }
    }
    
    /// Representative of the ``click`` track's current frame position.
    private var currentFrame: AVAudioFramePosition {
        guard
            let lastRenderTime = click.node.lastRenderTime,
            let playerTime = click.node.playerTime(forNodeTime: lastRenderTime)
        else {
          return 0
        }
        return playerTime.sampleTime
    }
    
    /// Represents the mixer's current state and updates the tracks, ``displayLink`` and other relevant properties to ensure smooth playback.
    public var playbackState: PlaybackState<AVAudioFramePosition> {
        get {
            PlaybackState.init(isPlaying: click.node.isPlaying, currentPosition: currentPosition)
        }
        set {
            switch newValue {
            case .playing:
                displayLink?.isPaused = false
            case .stopped:
                currentPosition = 0
                displayLink?.isPaused = true
                seekFrame = 0
            case .paused(let currentPosition):
                displayLink?.isPaused = true
                seekFrame = currentPosition
            }
            
            selectedPlayers.forEach {
                $0.update(from: newValue)
            }
            
            self.objectWillChange.send()
        }
    }
    
    /// If a surprise ``Fill`` is selected, it should be regenerated for the next play-thru of the mix, inheriting any modifications to its playback.
    private func replaceSurpriseIfNeeded() {
        func copyPlayerAttributes(from old: Track, to new: Track) {
            new.player.scaledPan = old.player.scaledPan
            new.player.sliderVolume = old.player.sliderVolume
            new.player.isMuted = old.player.isMuted
        }
        
        guard mix.selectedFills.count == 1 && mix.selectedFills.contains(where: { $0.isASurprise }) else { return }
        let old = Array(mix.selectedFills)[0]
        let surprise = Fill.allCases.randomElement()
        if let surprise {
            let oldAsTrack = Fill.asTrack(old)
            let surpriseAsTrack = Fill.asTrack(.surprise(surprise))
            if soloMode.tracks.contains(oldAsTrack) {
                soloMode.tracks.remove(oldAsTrack)
                soloMode.tracks.insert(surpriseAsTrack)
            }
            mix.selectedFills = []
            mix.tracks.insert(surpriseAsTrack)
            copyPlayerAttributes(from: oldAsTrack, to: surpriseAsTrack)
        }
    }
    
    /// If the mix is being played at the time the ``BrowseView`` play button is tapped, the mix is paused.
    public func pauseIfNeeded() {
        switch playbackState {
        case .playing(let currentTime):
            playbackState = .paused(currentTime)
        default: break
        }
    }
    
    private func setupDisplayLink() {
        displayLink = CADisplayLink(
            target: self,
            selector: #selector(updateDisplay))
        displayLink?.add(to: .current, forMode: .default)
        displayLink?.isPaused = true
    }
    
    /// Powers the changing time display as well as updates to ``playbackState``, ensuring all tracks stay in sync.
    @objc private func updateDisplay() {
        guard let file = click.file else { return }
        currentPosition = min(max((currentFrame + seekFrame), 0), file.length) // clamps currentPosition within the bounds of the file length
        
        if currentPosition >= file.length { // upon completion
          playbackState = .stopped
          seekFrame = 0
          currentPosition = 0
          replaceSurpriseIfNeeded()
            
            switch repeatMode {
            case .times(let times, let progress):
                if progress == times {
                    repeatMode = .times(times)
                } else {
                    repeatMode = .times(times, progress: progress + 1)
                    playbackState = .playing(0)
                }
            case .forever:
                playbackState = .playing(0)
            }
        }
    }
}
