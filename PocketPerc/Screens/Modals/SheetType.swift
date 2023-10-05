//
//  SheetType.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/27/23.
//

import SwiftUI

enum SheetType: Identifiable, View {
    case edit(Mixer)
    case delete(Track, _ action: () -> Void)
    
    var id: String {
        switch self {
        case .edit: "edit"
        case .delete: "delete"
        }
    }
    
    var body: some View {
        switch self {
        case .edit(let mixer): SheetView(mixer: mixer)
        case .delete(let track, let delete): DeleteWarning(trackName: track.displayName, delete: delete)
        }
    }
}
