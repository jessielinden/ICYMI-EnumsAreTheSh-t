//
//  CategoryTagView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 9/13/23.
//

import SwiftUI

struct CategoryTagView<ContentProvider: SelectableContentProvider>: View {
    let isSelected: (ContentProvider) -> Bool
    let action: (ContentProvider) -> Void
    
    init(isSelected: @escaping (ContentProvider) -> Bool, action: @escaping (ContentProvider) -> Void) {
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ContentProvider.category.header.foregroundStyle(.secondary)
            TagLayout(alignment: .leading) {
                ForEach(ContentProvider.allCases) { item in
                    item.buttonTextView(
                        isSelected: isSelected(item)) {
                        action(item)
                    }
                        .disabled(isSelected(item))
                        .id(item.id)
                }
            }
        }
    }
}

#Preview {
    StatefulPreviewWrapper(Fill.guitar) { fill in
        CategoryTagView<Fill>(
            isSelected: { fill in
                fill == Fill.guitar
            },
            action: { fill in })
    }
}
