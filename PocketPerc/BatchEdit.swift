//
//  BatchEdit.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/22/23.
//

import SwiftUI
import Combine

enum Change {
    case insert(Track)
    case remove(Track)
}

struct BatchEdit: View {
    @Environment(\.dismiss) var dismiss
    @Namespace var animation
    @StateObject var editor: Editor
    let playbackStateAction: PlaybackActionState
    let originalMix: Mix
    
    var mix: Mix {
        editor.mix
    }
    
    init(originalMix: Mix) {
        let editor = Editor(originalMix: originalMix)
        self.originalMix = originalMix
        playbackStateAction = .batchEdit(editor)
        _editor = StateObject(wrappedValue: editor)
    }
    
    var inCategories: [Category] {
        Array(Set(mix.tracks.map { $0.category })).sorted()
    }
    
    var unusedTracks: [Track] {
        Track.allCases.filter { !mix.tracks.contains($0) }
    }
    
    var categoriesForUnusedTracks: [Category] {
        Array(Set(unusedTracks.map { $0.category })).sorted()
    }
    
    var tracksToRemove: [Change] {
        var changes: [Change] = []
        originalMix.tracks.filter { !mix.tracks.contains($0) }.forEach { track in
            changes.append(.remove(track))
        }
        return changes
    }
    
    var tracksToInsert: [Change] {
        var changes: [Change] = []
        mix.tracks.filter { !originalMix.tracks.contains($0) }.forEach { track in
            changes.append(.insert(track))
        }
        return changes
    }
        
    let timer: AnyPublisher<Date,Never> = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect().eraseToAnyPublisher()
    
    var body: some View {
        VStack(spacing: 40) {
            
            VStack(spacing: 10) {
                Text("Preview")
                playbackControls
            }
            .padding()
            
            VStack(alignment: .leading, spacing: 20) {
                Section(header: Text("Mix".uppercased()).foregroundStyle(.secondary)) {
                    if inCategories.isEmpty {
                        Text("The mix is empty.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(inCategories) { category in
                            TagLayout(alignment: .leading) {
                                ForEach(Array(mix.tracks).filter { $0.category == category }.sorted()) { track in
                                    TagView2(
                                        track: track,
                                        previouslySelected:
                                            originalMix.tracks.contains(track), currentlySelected: mix.tracks.contains(track)) {
                                                withAnimation(.snappy) {
                                                    editor.mix.apply(.remove(track))
                                                }
                                            }
                                            .matchedGeometryEffect(id: track.displayName, in: animation)
                                }
                            }
                        }
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 20) {
                Section(header: Text("Available to add".uppercased()).foregroundStyle(.secondary)) {
                    ForEach(categoriesForUnusedTracks) { category in
                        VStack(alignment: .leading) {
                            Section(header: category.header) {
                                TagLayout(alignment: .leading) {
                                    ForEach(unusedTracks.filter { $0.category == category }.sorted()) { track in
                                        TagView2(
                                            track: track,
                                            previouslySelected:
                                                originalMix.tracks.contains(track), currentlySelected: mix.tracks.contains(track)) {
                                                    withAnimation(.snappy) {
                                                        editor.mix.apply(.insert(track))
                                                    }
                                                }
                                                .matchedGeometryEffect(id: track.displayName, in: animation)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            HStack {
                Button("reset") {
                    withAnimation(.snappy) {
                        editor.mix = originalMix
                    }
                }
                
                Button("confirm changes") {
                   // previousMix = mix
                    dismiss()
                }
            }
            .accentColor(.secondary)
            .buttonStyle(.borderedProminent)
            
            Spacer()
        }

        .onChange(of: mix.tracks) { oldValue, newValue in
            if oldValue.count > newValue.count {
                oldValue.forEach { track in
                 //   guard let player = track.node else { return }
//                    
//                    if player.isPlaying && !newValue.contains(track) {
//                        player.stop()
//                    }
                }
            }
        }
    }
}

extension BatchEdit {
    var playbackControls: some View {
        HStack(spacing: 15) {
            stopButton
          //  playPauseButton
            repeatButton
        }
        .buttonStyle(.plain)
    }
    
//    var playPauseButton: some View {
//        PlaybackControls.playPause(editor.playbackState) {
//            playbackStateAction.playPause()
//        }
//        .imageScale(.large)
//    }
    
    var stopButton: some View {
        PlaybackControls.stop {
            playbackStateAction.stop()
        }
        .disabled(editor.playbackState == .stopped)
    }
    
    var repeatButton: some View {
        PlaybackControls.repeating(repeatMode: editor.repeatMode) {
            playbackStateAction.toggleRepeatMode()
        }
        .foregroundColor(editor.repeatMode == .none ? .primary : .green)
    }
}

struct TagView2: View {
    var selectionState: SelectionState
    let track: Track
    let toggle: () -> Void
    
    init(track: Track, previouslySelected: Bool, currentlySelected: Bool, toggle: @escaping () -> Void) {
        self.track = track
        self.toggle = toggle
        self.selectionState = switch (previouslySelected, currentlySelected) {
        case (true, true): .selected(previously: .selected)
        case (false, true): .selected(previously: .unselected)
        case (false, false): .unselected(previously: .unselected)
        case (true, false): .unselected(previously: .selected)
        }
    }
    
    enum SelectionState: Equatable {
        case unselected(previously: PreviousSelectionState)
        case selected(previously: PreviousSelectionState)
        
        enum PreviousSelectionState: Equatable {
            case selected
            case unselected
        }
        
        var systemImage: String {
            switch self {
            case .unselected: "plus"
            case .selected: "xmark"
            }
        }
    }
    
    var previousSelectionState: SelectionState.PreviousSelectionState {
        switch selectionState {
        case .unselected(let previously):
            previously
        case .selected(let previously):
            previously
        }
    }
    
    var body: some View {
       styledButton()
    }
    
    var label: some View {
        Label(track.displayName, systemImage: selectionState.systemImage)
            .accentColor(.white)
    }
    
    var button: some View {
        Button {
            toggle()
        } label: {
            label
        }
    }
    
    @ViewBuilder func styledButton() -> some View {
        switch selectionState {
        case .unselected(previously: .selected):
            button
                .buttonStyle(.bordered)
                .background(RoundedRectangle(cornerRadius: 8).fill(track.category.color.opacity(0.7)))
        case .unselected(previously: .unselected):
            button
                .buttonStyle(.bordered)
        case .selected(let previously) where previously == .selected:
            button
                .accentColor(track.category.color)
                .buttonStyle(.borderedProminent)
        case .selected(let previously) where previously == .unselected:
            button
                .buttonStyle(.bordered)
                .background(RoundedRectangle(cornerRadius: 8).stroke(track.category.color, lineWidth: 3))
        default: button
        }
    }
}

#Preview {
  //  StatefulPreviewWrapper(Mix.sample) {
    BatchEdit(originalMix: Mix.sample)
 //   }
        .environmentObject(Mixer())
}
