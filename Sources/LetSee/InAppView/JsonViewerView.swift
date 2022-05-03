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
	var body: some View {
		VStack(alignment: .center, spacing: 16){
			HStack {
				Text("Send")
					.font(.headline.weight(.medium))
					.foregroundColor(Color.white)
				Image(systemName: "square.and.arrow.up.fill")
					.resizable()
					.scaledToFit()
					.foregroundColor(Color.white)
					.frame(width: 24, height: 24)
			}
			.frame(maxWidth: .infinity, alignment: .center)
			.padding()
			.background(Color.black)
			.cornerRadius(15)
			.onTapGesture {
				tap(mock)
			}

			ScrollView {
				Text(mock.formatted ?? "")
					.multilineTextAlignment(.leading)
					.font(.body)
					.foregroundColor(.black.opacity(1))
					.padding()
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			}
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
	}
}
