//
//  TagLayout.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/22/23.
//

import SwiftUI

// Kavsoft
struct TagLayout: Layout {
    var alignment: Alignment = .center
    var spacing: CGFloat = 10
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? 0
        var height: CGFloat = 0
        let rows = generateRows(maxWidth: maxWidth, proposal: proposal, subviews: subviews)
        
        for (index, row) in rows.enumerated() {
             // find max height of each row and add to total height
            if index == (rows.count - 1) {
                height += row.maxHeight(proposal)
                // (no spacing needed for last item)
            } else {
                height += row.maxHeight(proposal) + spacing
            }
        }
        
        return .init(width: maxWidth, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var origin = bounds.origin
        let maxWidth = bounds.width
        let rows = generateRows(maxWidth: maxWidth, proposal: proposal, subviews: subviews)
        
        for row in rows {
            // changing origin.x based on alignment
            let leading: CGFloat = bounds.maxX - maxWidth
            let trailing = bounds.maxX - (row.reduce(CGFloat.zero) { partialResult, view in
                let width = view.sizeThatFits(proposal).width
                if view == row.last { // no spacing
                    return partialResult + width
                } else {
                    return partialResult + width + spacing
                }
            })
            let center = (trailing + leading) / 2
            
            // resetting origin.x to zero in each row
            origin.x = (alignment == .leading ? leading : alignment == .trailing ? trailing : center)
            
            for view in row {
                let viewSize = view.sizeThatFits(proposal)
                view.place(at: origin, proposal: proposal)
                
                // updating origin.x
                origin.x += (viewSize.width + spacing)
            }
            
            // updaing origin.y
            origin.y += (row.maxHeight(proposal) + spacing)
        }
    }
    
    func generateRows(maxWidth: CGFloat, proposal: ProposedViewSize, subviews: Subviews) -> [[LayoutSubviews.Element]] {
        var row: [LayoutSubviews.Element] = []
        var rows: [[LayoutSubviews.Element]] = []
        
        var origin = CGRect.zero.origin
        
        for view in subviews {
            let viewSize = view.sizeThatFits(proposal)
            
            if (origin.x + viewSize.width + spacing) > maxWidth { // pushing to new row
                rows.append(row)
                row.removeAll()
                
                // resetting origin
                origin.x = 0
                row.append(view)
                
                // updating origin.x
                origin.x += viewSize.width + spacing
            } else { // adding item to same row
                row.append(view)
                
                // updating origin.x
                origin.x += viewSize.width + spacing
            }
        }
        
        // checking for any exhaust rows
        if !row.isEmpty {
            rows.append(row)
            row.removeAll()
        }
        
        return rows
    }
    
}

extension [LayoutSubviews.Element] {
    func maxHeight(_ proposal: ProposedViewSize) -> CGFloat {
        return self.compactMap { view in
            return view.sizeThatFits(proposal).height }.max() ?? 0
    }
}

#Preview {
    BrowseView(pauseIfNeeded: {})
        .environmentObject(BrowseManager())
}
