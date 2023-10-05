//
//  WelcomeView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/13/23.
//

import SwiftUI

struct WelcomeView: View {
    let dismiss: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(.logo)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .clipShape(.rect(cornerRadius: 10))
            
            Text("PocketPerc")
                .font(.title)
            
            Spacer()
            
            Button {
                withAnimation {
                   dismiss()
                }
            } label: {
                Text("Let's get started!")
                    .font(.title3)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.indigo.gradient, in: RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding()
        }
        .background()
    }
}

#Preview {
    WelcomeView(dismiss: {})
}
