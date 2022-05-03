//
//  MultilineTextView.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
import SwiftUI
import Combine

struct MultilineTextView: UIViewRepresentable {
	@Binding var text: String

	func makeUIView(context: Context) -> UITextView {
		let view = UITextView()
		view.isScrollEnabled = true
		view.isEditable = true
		view.isUserInteractionEnabled = true
		view.backgroundColor = .clear
		view.font = UIFont.systemFont(ofSize: 16)
		return view
	}

	func updateUIView(_ uiView: UITextView, context: Context) {
		let json = try? JSONSerialization.jsonObject(with: text.data(using: .utf8)!)

		let mattrs = NSMutableAttributedString(string: "", attributes: [.font: UIFont.systemFont(ofSize: 30)])
		mattrs.append(json)
		uiView.attributedText = mattrs
	}
}
