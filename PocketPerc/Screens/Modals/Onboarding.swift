//
//  Onboarding.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/22/23.
//

import SwiftUI

struct Onboarding: View {
    @Environment(\.dismiss) var dismiss
    @State private var onboardingState: OnboardingState = .welcome
    
    private enum OnboardingState: CaseIterable {
        case welcome
        case listen
    }
    
    var body: some View {
        Group {
            switch onboardingState {
            case .welcome:
                VStack(spacing: 20) {
                    Spacer()
                    Image(.logo)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    
                    Text("PocketPerc")
                        .font(.title)
                    
                    Spacer()
                    
                    Button {
                        withAnimation {
                            onboardingState.stepForward()
                        }
                    } label: {
                        Text("Let's get started!")
                            .font(.title3)
                            .fontWeight(.medium)
                            .frame(maxWidth: .infinity)
                    }
                    .padding()
                    .accentColor(.pink)
                    .buttonStyle(.borderedProminent)
                }
            case .listen: BrowseView(pauseIfNeeded: {}).transition(.move(edge: .trailing))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    Onboarding()
        .environmentObject(Mixer())
}
