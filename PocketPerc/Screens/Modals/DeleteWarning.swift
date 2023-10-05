//
//  DeleteWarning.swift
//  PocketPerc
//
//  Created by Jessica Linden on 7/24/23.
//

import SwiftUI

struct DeleteWarning: View {
    @Environment(\.dismiss) var dismiss
    let trackName: String
    let delete: () -> Void
    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("Are you sure you want to delete\n \(Text(trackName.uppercased()).bold().font(.title2))\n from your mix?")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                Text("This cannot be undone.")
            }
            
            HStack(spacing: 20) {
                Button("cancel") {
                    dismiss()
                }
                
                Button("delete") {
                    delete()
                    dismiss()
                }
                .tint(.red)
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .presentationDetents([.medium])
    }
}

#Preview {
    Text("")
        .sheet(isPresented: Binding.constant(true)) {
            DeleteWarning(trackName: Track.latin(.cowbell).displayName, delete: { })
        }
}
