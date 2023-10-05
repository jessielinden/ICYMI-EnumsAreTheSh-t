//
//  CaseIterable ext.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/29/23.
//

import Foundation

extension CaseIterable where Self: Equatable, AllCases.Index == Int {
    mutating func stepForward() {
        guard let nextIndex else { return }
        self = Self.allCases[nextIndex]
    }
    
    mutating func stepBackward() {
        guard let previousIndex else { return }
        self = Self.allCases[previousIndex]
    }

    func next() -> Self? {
        guard let nextIndex else { return nil }
        return Self.allCases[nextIndex]
    }
    
    func previous() -> Self? {
        guard let previousIndex else { return nil }
        return Self.allCases[previousIndex]
    }
    
    var nextIndex: Int? {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        
        return (currentIndex + 1) % allCases.count
    }
    
    var previousIndex: Int? {
        let allCases = Self.allCases
        guard let currentIndex = allCases.firstIndex(of: self) else { return nil }
        
        return (currentIndex - 1 + allCases.count) % allCases.count
    }
}
