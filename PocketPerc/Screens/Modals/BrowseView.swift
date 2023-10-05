//
//  BrowseView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/5/23.
//

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject var manager: BrowseManager
    let pauseIfNeeded: () -> Void
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            VStack {
                SheetState.browse.header
                
                Divider()
                
                SubscriptionView(content:
                    playbackControls, publisher: timer) { _ in
                    manager.updatePlaybackStateIfNeeded()
                }
                
                ViewThatFits(in: .vertical) {
                    tracks
                    
                    ScrollViewReader { proxy in
                        ScrollView {
                            tracks
                                .onChange(of: manager.selectedTrack?.id) { (_, id) in
                                    if let id {
                                        withAnimation {
                                            if manager.selectedCategory == .mallets {
                                                proxy.scrollTo(Category.mallets.label)
                                            } else {
                                                proxy.scrollTo(id, anchor: .center)
                                            }
                                        }
                                    }
                                }
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .dismissable()
        }
        .ignoresSafeArea()
    }
}

extension BrowseView {
    var tracks: some View {
        VStack(alignment: .leading, spacing: 40) {
            CategoryTagView<Mallets>(
                isSelected: { item in
                    item.id == manager.selectedTrack?.id
                }, action: { item in
                    manager.selectedTrack = item
                }
            )
            .id(Category.mallets.label)
            
            CategoryTagView<Latin>(
                isSelected: { item in
                    item.id == manager.selectedTrack?.id
                }, action: { item in
                    manager.selectedTrack = item
                }
            )
            
            CategoryTagView<Horns>(
                isSelected: { item in
                    item.id == manager.selectedTrack?.id
                }, action: { item in
                    manager.selectedTrack = item
                }
            )
            
            CategoryTagView<Rhythm>(
                isSelected: { item in
                    item.id == manager.selectedTrack?.id
                }, action: { item in
                    manager.selectedTrack = item
                }
            )
            
            CategoryTagView<Fill>(
                isSelected: { item in
                    item.id == manager.selectedTrack?.id
                }, action: { item in
                    manager.selectedTrack = item
                }
            )
        }
        .padding(.horizontal)
    }
    
    var playbackControls: some View {
        HStack {
            backwardButton
            stopButton
            playPauseButton
            forwardButton
            repeatButton
        }
        .dynamicTypeSize(...DynamicTypeSize.accessibility1)
        .padding()
    }
    
    var playPauseButton: some View {
        PlaybackControls.playPause(manager.playbackState.isPlaying) {
            pauseIfNeeded()
            manager.playPause()
        }
    }
    
    var stopButton: some View {
        PlaybackControls.stop {
            manager.stop()
        }
        .disabled(manager.playbackState == .stopped)
    }
    
    var forwardButton: some View {
        PlaybackControls.forward {
            manager.forward()
        }
        .disabled(manager.selectedTrack == nil)
    }
    
    var backwardButton: some View {
        PlaybackControls.backward {
            manager.backward()
        }
        .disabled(manager.selectedTrack == nil)
    }
    
    var repeatButton: some View {
        PlaybackControls.repeating(repeatMode: manager.repeatMode) {
            manager.repeatMode.toggle()
        }
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            SheetView(sheetState: .browse)
                .environmentObject(BrowseManager())
        }
}
