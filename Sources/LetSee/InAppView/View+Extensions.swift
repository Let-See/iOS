//
//  View+Extensions.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
extension View {
	@ViewBuilder
	func `if`<Content: View>(_ condition: ()->Bool, @ViewBuilder _ content: (Self)-> Content) -> some View {
		if condition() {
			content(self)
		} else {
			self
		}
	}
}
