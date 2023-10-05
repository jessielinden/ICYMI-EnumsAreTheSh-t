//
//  CarouselIndicator.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/5/23.
//

import SwiftUI

struct CarouselIndicator: View {
    var selection: Int
    var body: some View {
        VStack {
            HStack {
                ForEach(0..<5) { index in
                    Circle()
                        .fill(selection == index ? .primary : .secondary)
                        .frame(maxWidth: 15)
                }
            }
        }
        .padding()
    }
    
}

#Preview {
    VStack {
        CarouselIndicator(selection: 1)
            .frame(height: 200)
        
        CarouselIndicator(selection: 4)
            .frame(height: 200)
    }
}
