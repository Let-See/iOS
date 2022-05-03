//
//  JsonViewerView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
struct JsonViewerView: View {
	var tap: ((LetSeeMock) -> Void)
	var mock: LetSeeMock
	@State var tapped: Bool = false
	@State var text: String = ""
	var body: some View {
		VStack(alignment: .center, spacing: 16){
			HStack {
				Text("Send")
					.font(.headline.weight(.medium))
					.foregroundColor(Color.black)
				Image(systemName: "square.and.arrow.up.fill")
					.resizable()
					.scaledToFit()
					.foregroundColor(Color.black)
					.frame(width: 24, height: 24)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding()
			.background(Color.black.opacity(tapped ? 0.05 : 0.1))
			.cornerRadius(15)
			.disabled(tapped)
			.onTapGesture {
				tap(mock)
				tapped.toggle()
			}


			Group {
//				if #available(iOS 14.0, *) {
//					TextEditor(text: $text)
//
//				} else {
				MultilineTextView(text: $text)
//				}
			}
			.multilineTextAlignment(.leading)
			.font(.body)
			.foregroundColor(.black.opacity(1))
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			.background(Color.gray.opacity(0.15))
			.cornerRadius(10)
		}
		.if({true}, { view in
			if #available(iOS 14.0, *) {
				view
					.navigationTitle(mock.name)
					.navigationBarTitleDisplayMode(.inline)
			} else {
				view
					.navigationBarTitle(Text(mock.name)
						.font(.headline.weight(.heavy)))
			}
		})
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
		.onAppear {
			self.text = mock.formatted ?? ""
		}
	}
}

struct JsonViewer_Previews: PreviewProvider {
	static var previews: some View {
		JsonViewerView(tap: { mock in
			print(mock)
		}, mock: .success(name: "something", response: nil, data: "{\"name\": \"Salam sd sdfsd fds f sd f sd fs df sd fs dsd  sdfs df\"}"))
	}
}
