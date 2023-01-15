//
//  JsonViewerView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import LetSee
struct JsonViewerView: View {
	var tap: ((LetSeeMock) -> Void)
	var mock: LetSeeMock
	@State var tapped: Bool = false
	@State var text: String = ""
	@State var isEditable: Bool = false
	@Environment(\.colorScheme) var colorScheme
	var foreColor: Color {
		get {colorScheme == .dark ? Color.white : Color.black}
	}
	var body: some View {
		VStack(alignment: .center, spacing: 16){
			Button(action: {
				tap(mock.mapJson(text.data(using: .utf8)!))
				tapped.toggle()
			}, label: {
				HStack {
                    Text("Send")
					.font(.headline.weight(.medium))
					.foregroundColor(foreColor)
				Image(systemName: "square.and.arrow.up.fill")
					.resizable()
					.scaledToFit()
					.foregroundColor(foreColor)
					.frame(width: 24, height: 24)
                }
				.frame(maxWidth: .infinity, alignment: .center)
				.padding()
				.background(foreColor.opacity(tapped ? 0.05 : 0.1))
				.cornerRadius(15)
			})
			.disabled(tapped)
            HStack {
                Button("Copy JSON") {
                    UIPasteboard.general.string = mock.formatted
                }
                Spacer()
                Button("Past JSON") {
                    text = UIPasteboard.general.string ?? ""
                }
            }
			ZStack(alignment: .topTrailing){
				Group {
					MultilineTextView(text: $text, isEditingEnabled: $isEditable)
				}
				.multilineTextAlignment(.leading)
				.font(.body)
				.foregroundColor(foreColor.opacity(1))
				.padding()
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
				.cornerRadius(10)

				HStack(alignment: .center){
					if isEditable {
						Text("editing...")
							.opacity(0.3)
					} else{
						Text("Edit")
							.opacity(0.5)
					}
					Button(action: {
						self.isEditable.toggle()
					}, label: {
						if self.isEditable {
							Image(systemName: "arrow.down.circle.fill")
								.resizable()
						} else {
							Image(systemName: "pencil.circle.fill")
								.resizable()
						}
					})
					.foregroundColor(!self.isEditable ? .blue : .green)
					.frame(width: 32, height: 32, alignment: .center)
					.opacity(0.8)


				}.padding([.top, .trailing], 8)
			}
		}
		.if({true}, { view in
				view
					.navigationTitle(mock.name)
					.navigationBarTitleDisplayMode(.inline)
		})
			.padding()
			.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
			.onAppear {
			self.text = mock.formatted ?? ""
		}
	}
}

#if DEBUG
//struct JsonViewer_Previews: PreviewProvider {
//	static var previews: some View {
//		JsonViewerView(tap: { mock in
//			print(mock)
//		}, mock: .success(name: "something", response: nil, data: "{\"name\": \"Salam sd sdfsd fds f sd f sd fs df sd fs dsd  sdfs df\"}"))
//	}
//}
#endif
