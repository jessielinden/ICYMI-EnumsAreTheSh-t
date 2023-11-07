//
//  AudioEnginePlayer.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/16/23.
//

import AVFoundation

/// Holds all audio components for playing a ``Track`` via the ``Mixer``.
/// The ``key`` is used to initialize a ``file``, which is read into the ``buffer``.
/// The ``node`` holds all available playback information.
final class AudioEnginePlayer: ObservableObject, Equatable {
    let key: String
    @Published var node = AVAudioPlayerNode()
    var file: AVAudioFile?
    var buffer: AVAudioPCMBuffer?
    
    init(key: String) {
        self.key = key
        
        guard let fileURL = Bundle.main.url(forResource: key, withExtension: "mp3") else {
            fatalError("Audio file for \(key) not found")
        }
        do {
            let file = try AVAudioFile(forReading: fileURL)
            let buffer = AVAudioPCMBuffer(pcmFormat: file.processingFormat, frameCapacity: AVAudioFrameCount(file.length))
            
            if let buffer {
                do {
                    self.buffer = buffer
                    try file.read(into: buffer)
                } catch {
                    print("Couldn't schedule buffer for \(key), \(error)")
                }
            } else {
                print("Buffer for \(key) is nil")
            }
            
            self.file = file
            
        } catch {
            self.file = nil
            self.buffer = nil
            print("Could not create file for key \(key)")
        }
        
        isMuted = true
    }
    
    /// Stores the volume before muting in order to restore to that volume if it exists, as opposed to full volume.
    private var previousVolume: Float? = 1
    
    /// Provided to ``TrackControls/mute(_:)``  via ``TrackView``.
    var isMuted: Bool {
        get { node.volume == 0 }
        set {
            switch newValue {
            case true: node.volume = 0
            case false: node.volume = previousVolume ?? 1
            }
            self.objectWillChange.send()
        }
    }
    
    /// Updated when ``Mixer/soloMode`` is toggled..
    var wasMutedWhenSoloModeWasTurnedOn: Bool?
    /// Provides ``wasMutedWhenSoloModeWasTurnedOn`` with the value of ``isMuted``.
    func updateWasMutedWhenSoloModeWasTurnedOn() {
        wasMutedWhenSoloModeWasTurnedOn = isMuted
    }
    
    /// Provided to ``TrackControls/volume(_:)``  via ``TrackView``.
    public var sliderVolume: Float {
        get {
            previousVolume ?? node.volume
        }
        set {
            node.volume = newValue
            
            if newValue != 0 {
                previousVolume = newValue
            }
        }
    }
    
    private var panValue: Float {
        node.pan
    }
    
    /// Provided to ``TrackControls/pan(_:)``  via ``TrackView``.
    /// Scaled for the size of a circle.
    public var scaledPan: CGFloat {
        get {
            CGFloat(panValue * 135)
        }
        set {
            node.pan = Float(newValue) / 135
            self.objectWillChange.send() // why is this needed here and for isMuted but not for sliderVolume?
        }
    }
    
    /// Handles playback and scheduling changes to the ``node`` per a change to the ``PlaybackState``.
    /// - Parameter playbackState: The newValue from``Mixer/playbackState``.
    func update(from playbackState: PlaybackState<AVAudioFramePosition>) {
        switch playbackState {
        case .playing: 
            node.play()
        case .stopped:
            node.stop()
            scheduleAudio()
        case .paused(let framePosition):
            node.stop()
            scheduleAudio(at: framePosition)
        }
    }
    
    /// Schedules a full buffer or a segment of the audio to play.
    /// - Parameter framePosition: The starting frame for playback.
    func scheduleAudio(at framePosition: AVAudioFramePosition? = nil) {
        guard let file else { return }
        
        if let framePosition {
            node.scheduleSegment(file, startingFrame: framePosition, frameCount: AVAudioFrameCount(file.length - framePosition), at: nil)
        } else {
            if let buffer {
                node.scheduleBuffer(buffer, at: nil, options: [.loops])
            }
        }
    }
    
    static func ==(lhs: AudioEnginePlayer, rhs: AudioEnginePlayer) -> Bool {
        lhs.key == rhs.key
    }
}


