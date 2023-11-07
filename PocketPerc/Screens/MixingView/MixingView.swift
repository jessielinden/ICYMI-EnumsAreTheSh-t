//
//  MixingView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/14/23.
//

import SwiftUI

struct MixingView: View {
    @ObservedObject var mixer: Mixer
    @Binding var sheetType: SheetType?
    @State private var sortStyle: SortStyle = .alphabetical
    @State private var filteredCategory: Category?

    private var sortedTracks: [Track] {
        let sorted = switch sortStyle {
        case .alphabetical: tracks.sorted { $0.displayName < $1.displayName }
        case .category: tracks.sorted()
        }
        
        guard let filteredCategory else { return sorted }
        return sorted.filter { $0.category == filteredCategory }
    }
    
    private var tracks: [Track] {
        Array(mixer.mix.tracks)
    }
    
    var body: some View {
        VStack(spacing: 40) {
            switch mixer.mix {
            case .empty:
                ContentUnavailableView("Add some tracks to your mix!", systemImage: "music.note.list")
            case .contains:
                VStack(spacing: 0) {
                    VStack(spacing: 20) {
                        HStack(spacing: 20) {
                            playbackControls
                            
                            Rectangle().frame(width: 1)
                            
                            Group {
                                sortMenu
                                filterMenu
                            }
                            .buttonStyle(.plain)
                            
                        }
                        .fixedSize(horizontal: false, vertical: true)
                        
                        SeekBar(
                            currentTime: $mixer.seekTime,
                            scrubbing: $mixer.scrubbing,
                            maxTime: mixer.maxTime)
                    }
                    .padding(.vertical)
                }
                trackList
                    .padding(.top, -55)
            }
        }
        .padding()
        .edgesIgnoringSafeArea(.bottom)
    }
}

extension MixingView {
    enum SortStyle: String, CaseIterable, Identifiable, MenuSelectable {
        case alphabetical
        case category
        
        var id: Self { self }
        var label: String { self.rawValue }
        
        static func <(lhs: SortStyle, rhs: SortStyle) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }
}

private protocol MenuSelectable {
    var label: String { get }
}
extension MenuSelectable {
    @ViewBuilder func menuOptionTextLabel(selected: Bool) -> some View {
        if selected {
            Label(label, systemImage: "checkmark")
        } else {
            Text(label)
        }
    }
}
extension Category: MenuSelectable {}

fileprivate struct SectionHeaderModifier: ViewModifier {
    let label: String?
    func body(content: Content) -> some View {
        if let label {
            Section(header: Text(label)) {
                content
            }
        } else {
            content
        }
    }
}

fileprivate extension View {
    func applySectionHeaderIfFiltered(label: String?) -> some View {
        modifier(SectionHeaderModifier(label: label))
    }
}

extension MixingView {
    var trackList: some View {
        List {
            ForEach(sortedTracks) { track in
                let soloed: Binding<Bool> = Binding(
                    get: {
                        mixer.soloMode.tracks.contains(track)
                    },
                    set: { shouldBeSoloed in
                        if shouldBeSoloed {
                            mixer.soloMode.insert(track)
                        } else {
                            mixer.soloMode.remove(track)
                        }
                    }
                )
                
                TrackView(track: track, soloed: soloed)
                    .swipeActions {
                        Button {
                            sheetType = .delete(track) { mixer.mix.remove(track) }
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
            }
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
            .applySectionHeaderIfFiltered(label: filteredCategory?.label)
        }
    }
    
    var playbackControls: some View {
        HStack {
            stopButton
            playPauseButton
            repeatButton
            soloButton
        }
    }
    
    var soloButton: some View {
        TrackControls.solo($mixer.isInSoloMode)
        .foregroundColor(mixer.isInSoloMode ? .red : .secondary)
    }
    
    var playPauseButton: some View {
        PlaybackControls.playPause(mixer.playbackState.isPlaying) {
            mixer.playbackState.toggle()
        }
    }
    
    var stopButton: some View {
        PlaybackControls.stop {
            mixer.playbackState = .stopped
        }
        .disabled(mixer.playbackState == .stopped)
    }
    
    var repeatButton: some View {
        PlaybackControls.repeating(repeatMode: mixer.repeatMode) {
            mixer.repeatMode.toggle()
        }
    }
    
    var sortMenu: some View {
        Menu {
            ForEach(SortStyle.allCases) { style in
                Button {
                    withAnimation {
                        sortStyle = style
                    }
                } label: {
                    style.menuOptionTextLabel(selected: sortStyle == style)
                }
            }
        } label: {
            Label(sortStyle.rawValue, systemImage: "arrow.up.arrow.down")
                .labelStyle(.iconOnly)
        }
    }
    
    var filterMenu: some View {
        Menu {
            ForEach(Category.allCases) { category in
                Button {
                    withAnimation {
                        if filteredCategory == category {
                            filteredCategory = nil
                        } else {
                            filteredCategory = category
                        }
                    }
                } label: {
                    category.menuOptionTextLabel(selected: filteredCategory == category)
                }
                .disabled(!tracks.contains(where: { $0.category == category }) || Set(tracks.map { $0.category }).count == 1)
            }
            
            if filteredCategory != nil {
                Button("clear filter") { filteredCategory = nil }
            }
        } label: {
            Label(sortStyle.rawValue, systemImage: "line.3.horizontal.decrease.circle")
                .symbolVariant(filteredCategory == nil ? .none : .fill)
                .labelStyle(.iconOnly)
        }
    }
}

#Preview("ContentView") {
    let mixer = Mixer(mix: Mix.sample3)
    return MixingView(mixer: mixer, sheetType: Binding.constant(.edit(mixer)))
        .preferredColorScheme(.dark)
}

#Preview("Empty Mix") {
    let mixer = Mixer(mix: .empty)
    return MixingView(mixer: mixer, sheetType: Binding.constant(.edit(mixer)))
}
