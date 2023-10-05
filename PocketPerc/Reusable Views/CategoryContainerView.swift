//
//  CategoryContainerView.swift
//  PocketPerc
//
//  Created by Jessica Linden on 8/5/23.
//

import SwiftUI

struct CategoryContainerView<ContentProvider: SelectableContentProvider, SurpriseButton: View>: View {
    @Binding var selections: Set<ContentProvider>
    let surpriseButton: SurpriseButton?
    
    init(
        selections: Binding<Set<ContentProvider>>,
        @ViewBuilder surpriseButton: @escaping () -> SurpriseButton? = { EmptyView() }) {
        self._selections = selections
        self.surpriseButton = surpriseButton()
    }
    
    var color: Color {
        ContentProvider.category.color
    }
    
    var sortedGroups: [[ContentProvider]] {
        ContentProvider.displayGroups.sorted(by: {
            $0[0] < $1[0]
        })
    }
    
    fileprivate var selectionState: SelectionState {
        selections.count == ContentProvider.allCases.count ? .all : selections.count > 0 ? .partial : .none
    }
 
    var body: some View {
        VStack(alignment: .leading) {
            Section(header:
                        HStack {
                ContentProvider.category.header
                Spacer()
                
                surpriseButton
                selectionStateButton
            }
                .accentColor(.primary)
            ) {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(sortedGroups.prefix(4), id: \.self) { group in
                            if group.count > 1 {
                                HStack {
                                    if let groupName = group.first?.rawValue.root {
                                        Text(groupName)
                                    }
                                    TagLayout(alignment: .leading, spacing: 8) {
                                        ForEach(group, id: \.self) { item in
                                            item.buttonTextView(
                                                isSelected: selections.contains(item),
                                                text: item.rawValue.suffix) {
                                                    updateSelectedTracks(with: item)
                                                }
                                        }
                                    }
                                }
                            } else if let item = group.first {
                                item.buttonTextView(
                                    isSelected: selections.contains(item)) {
                                        updateSelectedTracks(with: item)
                                    }
                            }
                        }
                    }
                    if sortedGroups.count > 4 {
                        VStack(alignment: .trailing) {
                            ForEach(sortedGroups.suffix(sortedGroups.count - 4), id: \.self) { group in
                                if group.count > 1 {
                                    HStack {
                                        if let groupName = group.first?.rawValue.root {
                                            Text(groupName)
                                        }
                                        TagLayout(alignment: .leading, spacing: 8) {
                                            ForEach(group, id: \.self) { item in
                                                item.buttonTextView(
                                                    isSelected: selections.contains(item),
                                                    text: item.rawValue.suffix) {
                                                        updateSelectedTracks(with: item)
                                                    }
                                            }
                                        }
                                    }
                                } else if let item = group.first {
                                    item.buttonTextView(
                                        isSelected: selections.contains(item)) {
                                            updateSelectedTracks(with: item)
                                        }
                                }
                            }
                        }
                    } else {
                        Spacer()
                    }
                }
            }
        }
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).stroke(ContentProvider.category.color, lineWidth: 3))
        .contentShape(Rectangle())
    }
    
    
    /// The button action for each instrument.
    /// - Parameters:
    ///   - item: An option.
    ///   - group: A collection of an item's associated values. Used if reciprocal selection/deselection is desired amongst the collection.
    // note: Not currently forcing reciprocal selection/deselection.
    func updateSelectedTracks(with item: ContentProvider, in group: [ContentProvider]? = nil) {
        if selections.contains(item) {
            selections.remove(item)
        } else {
            if let group {
                group.forEach { otherItem in
                    if selections.contains(otherItem) {
                        selections.remove(otherItem)
                    }
                }
            }
            selections.insert(item)
        }
    }
    
    var selectionStateButton: some View {
        Button {
            if selections.isEmpty {
                ContentProvider.displayGroups.forEach { group in
                    if let first = group.first {
                        selections.insert(first)
                    }
                }
            } else {
                selections = []
            }
        } label: {
            Image(systemName: "gift")
                .hidden()
                .overlay(
            Image(systemName: selectionState.systemName))
        }
    }
}

private enum SelectionState {
    case none, all, partial
    
    var systemName: String {
        switch self {
        case .none: "square"
        case .all: "checkmark.square.fill"
        case .partial : "minus.square"
        }
    }
}

extension CategoryContainerView where SurpriseButton == EmptyView {
  init(selections: Binding<Set<ContentProvider>>) {
    self.init(selections: selections, surpriseButton: { EmptyView() })
  }
}

#Preview {
    VStack(spacing: 20) {
        StatefulPreviewWrapper([Latin.cowbell]) {
            CategoryContainerView(selections: $0)
        }
        
        StatefulPreviewWrapper([Rhythm.guitar]) {
            CategoryContainerView(selections: $0)
        }
        
        StatefulPreviewWrapper([Fill.glock]) {
            CategoryContainerView(selections: $0) { Button { print("it'll be a surprise!") } label: { Image(systemName: "gift").buttonStyle(.bordered) }}
        }
    }
}
