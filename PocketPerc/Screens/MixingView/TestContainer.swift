//
//  TestContainer.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/13/23.
//

import SwiftUI

struct TestContainer: View {
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(0..<4) { index in
                    TestChild(label: "\(index)")
                        .containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: 8)
                        .scrollTargetLayout()
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .scrollTargetBehavior(.viewAligned)
    }
}

struct TestChild: View {
    let label: String
    var body: some View {
        Text(label)
            .padding()
            .frame(maxWidth: .infinity)
            .background(.indigo)
    }
}

#Preview {
    TestContainer()
}
