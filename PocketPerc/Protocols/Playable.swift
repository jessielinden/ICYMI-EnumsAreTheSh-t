//
//  Playable.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/6/23.
//

import Foundation

/// The audio-related requirements of objects under the ``SelectableContentProvider`` umbrella.
protocol Playable {
    var player: AudioEnginePlayer { get }
    var audioFileKey: String { get }
}
