//
//  SeekBar.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/6/23.
//

import SwiftUI

struct SeekBar: View {
    @Binding var currentTime: Double
    @Binding var scrubbing: Bool
    let maxTime: Double
    
    var body: some View {
        HStack {
            Text(TimeFormatter.format(currentTime))
            
            Slider(value: $currentTime, in: 0...maxTime, onEditingChanged: { scrubbing in
                self.scrubbing = scrubbing
            })
            
            Text(TimeFormatter.format(maxTime - currentTime))
        }
        .accentColor(.primary)
    }
}

enum TimeFormatter {
    static let secsPerMin = 60
    static let secsPerHour = TimeFormatter.secsPerMin * 60
    
    static func format(_ time: Double) -> String {
        var seconds = Int(ceil(time))
        var hours = 0
        var mins = 0
        
        if seconds > TimeFormatter.secsPerHour {
            hours = seconds / TimeFormatter.secsPerHour
            seconds -= hours * TimeFormatter.secsPerHour
        }
        
        if seconds > TimeFormatter.secsPerMin {
            mins = seconds / TimeFormatter.secsPerMin
            seconds -= mins * TimeFormatter.secsPerMin
        }
        
        var formattedString = ""
        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }
        formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", seconds))"
        return formattedString
    }
}

#Preview {
    StatefulPreviewWrapper(0.0) { currentTime in
        StatefulPreviewWrapper(false) { scrubbing in
            SeekBar(currentTime: currentTime, scrubbing: scrubbing, maxTime: 14)
        }
    }
}
