//
//  ContentView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 4/26/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject var mixer: Mixer = Mixer()
    @StateObject var browseManager = BrowseManager()
    @State private var sheetType: SheetType?
    @State private var viewState: ViewState = .welcome
    
    enum ViewState {
        case welcome
        case mixing
    }
    
    var body: some View {
        switch viewState {
        case .welcome:
            WelcomeView(dismiss: {
                viewState = .mixing
            })
            .animation(.default, value: viewState)
            .transition(.move(edge: .leading))
        case .mixing:
            NavigationView {
                MixingView(mixer: mixer, sheetType: $sheetType)
                    .navigationBarTitle("Mix")
                    .toolbar {
                        Button {
                            sheetType = .edit(mixer)
                        } label: {
                            Image(systemName: "plus")
                                .foregroundColor(.primary)
                        }
                        .buttonStyle(.bordered)
                    }
                    .sheet(item: $sheetType) { sheetType in
                        sheetType
                    }
            }
            .environmentObject(browseManager)
        }
    }
}

#Preview{
    ContentView()
        .preferredColorScheme(.dark)
}

