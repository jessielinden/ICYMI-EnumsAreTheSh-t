//
//  PlaybackActionState.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/23/23.
//

import Foundation

enum PlaybackActionState {
    case mixing(Mixer)
    case browse(BrowseManager)
    
    func playPause() {
        switch self {
        case .mixing(let mixer):
            mixer.playbackState.toggle()
        case .browse(let manager):
            manager.playPause()
        }
    }
    
    func stop() {
        switch self {
        case .mixing(let mixer):
            mixer.playbackState = .stopped
        case .browse(let manager):
            manager.stop()
        }
    }
    
    func toggleRepeatMode() {
        switch self {
        case .mixing(let mixer):
            mixer.repeatMode.toggle()
        case .browse(let manager):
            manager.repeatMode.toggle()
        }
    }
    
    func forward() {
        guard case .browse(let browseManager) = self else {
            return
        }
        browseManager.forward()
    }
    
    func backward() {
        guard case .browse(let browseManager) = self else {
            return
        }
        browseManager.backward()
    }
}
