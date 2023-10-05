//
//  Drumset.swift
//  PocketPerc
//
//  Created by Jessica Linden on 4/26/23.
//

import Foundation

enum Drumset {
    
    case snare
    case hihat
    case crash
    case ride
    case rackTom
    case floorTom
    
    var percussionType: Category {
        return Category.rhythm
    }
}
