//
//  StatefulPreviewWrapper.swift
//  PocketPerc
//
//  Created by Jessica Linden on 6/27/23.
//

import SwiftUI

/// Used for previews where `@Binding` properties are present.
struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State var value: Value
    var content: (Binding<Value>) -> Content

    var body: some View {
        content($value)
    }
    
    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(wrappedValue: value)
        self.content = content
    }
}
