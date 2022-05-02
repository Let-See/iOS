//
//  MocksListView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
struct MocksListView: View {
	var tap: ((LetSeeMock) -> Void)
	var request: LetSeeUrlRequest
	var body: some View {
		ScrollView{
			VStack(alignment: .leading, spacing: 16) {
				HStack{
					Text("for:")
						.font(.subheadline)

					Text((request.request.url?.absoluteString ?? ""))
						.font(.headline)
						.multilineTextAlignment(.leading)
				}
				ForEach(request.mocks ?? [], id: \.hashValue) { mock in
					VStack {
						NavigationLink {
							JsonViewerView(tap: self.tap, mock: mock)
						} label: {
							HStack {
								Group {
									if case .success(_, _) = mock {
										Image(systemName: "checkmark.diamond")
											.resizable()
											.foregroundColor(Color(hex: "#339900"))

									} else {
										Image(systemName: "xmark.diamond")
											.resizable()
											.foregroundColor(Color(hex: "#cc3300"))
									}
								}
								.scaledToFit()
								.frame(width: 24, height: 24)

								VStack{
									Text(mock.name)
										.font(.subheadline.weight(.medium))
										.foregroundColor(Color.black)
										.frame(maxWidth: .infinity, alignment: .leading)
									Group {
										if case .success(_, _) = mock {
											Text("Success")
												.font(.caption.weight(.medium))
												.foregroundColor(Color(hex: "#339900"))

										} else {
											Text("Error")
												.font(.caption.weight(.medium))
												.foregroundColor(Color(hex: "#cc3300"))
										}
									}
									.font(.subheadline.weight(.medium))
									.frame(maxWidth: .infinity, alignment: .leading)
								}
								Image(systemName: "chevron.right")
									.foregroundColor(.gray)

							}

						}
						Divider()
					}
					.frame(maxWidth: .infinity, alignment: .leading)
				}
				Spacer()
			}
			.if({true}, { view in
				if #available(iOS 14.0, *) {
					view
						.navigationTitle("Mocks")
						.navigationBarTitleDisplayMode(.large)
				} else {
					view
						.navigationBarTitle(Text("Mocks")
							.font(.headline.weight(.heavy)))
				}
			})
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
		}
	}
}
