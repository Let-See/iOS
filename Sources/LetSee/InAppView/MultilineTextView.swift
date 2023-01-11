//
//  MultilineTextView.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
import SwiftUI
import Combine

// first wrap a UITextView in a UIViewRepresentable
struct MultilineTextView: View {
    @Binding var text: String
    @Binding var isEditingEnabled: Bool
    var body: some View {
            TextEditor(text: $text)
                .disabled(!isEditingEnabled)
    }
}

fileprivate extension NSMutableAttributedString {
    func append(_ element: Any?) {
        return append(.render(element))
    }
}
