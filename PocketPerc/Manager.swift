//
//  Manager.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/14/23.
//

import SwiftUI

class Manager: ObservableObject {
    @Published var selectedTracks: Set<Track> = [.mallets(.marimba), .latin(.bongos)]
    @Published var sheetType: SheetType?
    
    static let tracks = Track.allCases // is this useful? if it's not, neither is the 

    var selectedMallets: Set<Mallets> { // these unmuted properties are essentially an endeavor to preserve the single source of truth (unmuted Set<Track>) thus needing a conversion if the CategoryView is going to get a collection of the "sub-enum". The mallets one works well enough bc we can just use the root. What about a case that has associated values? Latin has (had) no raw type so it had no "accessible initializer". I wrote an init and now it works. the compactMap part is because the enum inits are actually init?, so we need to account for optionality

        get { // make something to replace the Mallets(rawValue: $0.suffix) to complement the asTrack static methods in the sub-enums
            Set(selectedTracks.filter { $0.category == .mallets }.map { Mallets(rawValue: $0.suffix) }.compactMap { $0 }) // should I give Mallets (and all other potential subenums) an init? like the one from Latin so that the suffix thing is irrelevant?
        }
        set {
            selectedMallets.forEach {
                selectedTracks.remove(Mallets.asTrack($0))
            }
            let newValueAsPerc = newValue.map { Mallets.asTrack($0) }
            newValueAsPerc.forEach {
                selectedTracks.insert($0)
            }
        }
    }
    
    var selectedLatin: Set<Latin> {
        get {
            Set(selectedTracks.filter { $0.category == .latin }.map { Latin(from: $0) }.compactMap { $0 })
        }
        set {
            selectedLatin.forEach {
                selectedTracks.remove(Latin.asTrack($0))
            }
            
            let newValueAsPerc = newValue.map { Latin.asTrack($0) }
            newValueAsPerc.forEach {
                selectedTracks.insert($0)
            }
        }
    }
}

