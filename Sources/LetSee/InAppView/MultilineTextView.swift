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
struct MultilineTextView: UIViewRepresentable {
	@Binding var text: String
	@Binding var isEditingEnabled: Bool
	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	func makeUIView(context: Context) -> UITextView {
		let textView = UITextView()
		textView.isScrollEnabled = true
		textView.isEditable = true
		textView.backgroundColor = .clear
		textView.font = UIFont.systemFont(ofSize: 16)
		textView.delegate = context.coordinator
		return textView
	}

	func updateUIView(_ uiView: UITextView, context: Context) {
		uiView.isEditable = isEditingEnabled
		guard !isEditingEnabled else {return}
//		uiView.text = text
		guard let jsonData = text.data(using: .utf8), let jsonObject = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!)
		else {
			uiView.attributedText = nil
			uiView.text = text
			return
		}

		let mattrs = NSMutableAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 30)])
		mattrs.append(jsonObject)
		uiView.attributedText = mattrs
	}

	class Coordinator : NSObject, UITextViewDelegate {

		var parent: MultilineTextView

		init(_ uiTextView: MultilineTextView) {
			self.parent = uiTextView
		}

		func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
			return true
		}

		func textViewDidChange(_ textView: UITextView) {
			print("new text: \(String(describing: textView.text!))")
			self.parent.text = textView.text
				.replacingOccurrences(of: "”", with: "\"")
				.replacingOccurrences(of: "“", with: "\"")
				.replacingOccurrences(of: "‘", with: "'")
				.replacingOccurrences(of: "’", with: "'")
		}
	}
}
