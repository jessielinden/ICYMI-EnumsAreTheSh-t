//
//  Mix.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/27/23.
//

import Foundation

// https://appventure.me/guides/advanced_practical_enum_examples/advanced_enum_usage/generic_enums.html

/// Maintains a set of tracks.
/// Facilitates selection in the ``QuickSelectView`` by converting objects of type ``Track`` to their respective wrapped value, and back.
enum Mix: Equatable {
    case empty // a la LoadingState where this represents the loading case, probably fine if the UI for empty because the user is onboarding would work for empty because the user has cleared out their mix but they know how the app works, which I think is the case here.
    case contains(Set<Track>)
    
    var tracks: Set<Track> {
        get {
            switch self {
            case .empty: []
            case .contains(let tracks): tracks
            }
        }
        set {
            if newValue.isEmpty {
                self = .empty
            } else {
                self = .contains(newValue)
            }
        }
    }
    
    mutating func remove(_ track: Track) {
        tracks.remove(track)
    }
    
    mutating func insert(_ track: Track) {
        tracks.insert(track)
    }
    
    func contains(_ track: Track) -> Bool {
        tracks.contains(track)
    }

    static let sample = Mix.contains([.mallets(.marimba)])
    static let sample3 = Mix.contains([.mallets(.marimba), .mallets(.vibraphone), .latin(.clave(.threeTwo))])
    static let sample5 = Mix.contains([.mallets(.marimba), .latin(.clave(.threeTwo)), .horns(.trumpet), .rhythm(.bass(.synth)), .fill(.guitar)])
    static let sample8 = Mix.contains([.mallets(.marimba), .mallets(.vibraphone), .latin(.clave(.threeTwo)), .latin(.bongos), .latin(.shaker), .rhythm(.drums(.acoustic)), .rhythm(.bass(.electric)), .fill(.vibraslap)])
    static let sample12 = Mix.contains([.mallets(.marimba), .mallets(.vibraphone), .latin(.clave(.threeTwo)), .latin(.bongos), .latin(.shaker), .rhythm(.drums(.acoustic)), .rhythm(.bass(.electric)), .fill((.vibraslap)), .fill(.guitar), .rhythm(.guitar), .rhythm(.keys(.piano)), .latin(.agogo)])
    static let sample15 = Mix.contains([.mallets(.marimba), .mallets(.vibraphone), .latin(.clave(.threeTwo)), .latin(.bongos), .latin(.shaker), .rhythm(.drums(.acoustic)), .rhythm(.bass(.electric)), .fill((.vibraslap)), .fill(.guitar), .rhythm(.guitar), .rhythm(.keys(.piano)), .latin(.agogo), .latin(.cabasa), .horns(.section), .fill(.drums(.electric))])
}

extension Mix {
    var selectedMallets: Set<Mallets> {
        get {
            switch self {
            case .empty: []
            case .contains(let tracks):
                Set(tracks.filter { $0.category == .mallets }
                    .compactMap { Mallets(from: $0) })
            }
        }
        
        set {
            let oldValue = selectedMallets
            updateTracks(with: newValue, comparedTo: oldValue)
        }
    }
    
    var selectedLatin: Set<Latin> {
        get {
            switch self {
            case .empty: []
            case .contains(let tracks):
                Set(tracks.filter { $0.category == .latin }
                    .compactMap { Latin(from: $0) })
            }
        }
        
        set {
            let oldValue = selectedLatin
            updateTracks(with: newValue, comparedTo: oldValue)
        }
    }
    
    var selectedHorns: Set<Horns> {
        get {
            switch self {
            case .empty: []
            case .contains(let tracks):
                Set(tracks.filter { $0.category == .horns }
                    .compactMap { Horns(from: $0) })
            }
        }
        set {
            let oldValue = selectedHorns
            updateTracks(with: newValue, comparedTo: oldValue)
        }
    }
    
    var selectedRhythmSection: Set<Rhythm> {
        get {
            return switch self {
            case .empty: []
            case .contains(let tracks):
                Set(tracks.filter { $0.category == .rhythm }
                    .compactMap { Rhythm(from: $0) })
            }
        }
        
        set {
            let oldValue = selectedRhythmSection
            updateTracks(with: newValue, comparedTo: oldValue)
        }
    }
    
    var selectedFills: Set<Fill> {
        get {
            return switch self {
            case .empty: []
            case .contains(let tracks):
                Set(tracks.filter { $0.category == .fill }
                    .compactMap { Fill(from: $0) })
            }
        }
        
        set {
            let oldValue = selectedFills
            if oldValue.contains(where: { $0.isASurprise }) { // filter out the surprise instance and then update self.tracks
                updateTracks(with: newValue.filter { !$0.isASurprise }, comparedTo: oldValue)
            } else {
                updateTracks(with: newValue, comparedTo: oldValue)
            }
        }
    }
    
    private mutating func updateTracks<T: SelectableContentProvider>(with newValue: Set<T>, comparedTo oldValue: Set<T>) {
        oldValue.forEach {
            if !newValue.contains($0) {
                tracks.remove(T.asTrack($0))
            }
        }
        let newValueAsTracks = newValue.map { T.asTrack($0) }
        newValueAsTracks.forEach {
            tracks.insert($0)
        }
    }
}

