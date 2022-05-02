//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine

public struct LetSeeView: View {
	public unowned var letSee: LetSee
	public init(letSee: LetSee) {
		self.letSee = letSee
	}
	public var body: some View {
		NavigationView{
			ScrollView{
				VStack(spacing: 16){
					Spacer()
					Text("Server Address. you can open this address in your machine to see the logs")
						.font(.subheadline)
					HStack {
						Text("\(letSee.address)")
							.font(.headline)
							.frame(maxWidth: .infinity, alignment: .leading)

						Button("copy") {
							// write to clipboard
							UIPasteboard.general.string = letSee.address
						}
					}
					.padding()

					RequestsListView(viewModel: .init(letSee: letSee))
						.frame(maxWidth: .infinity)
						.padding()
					Spacer()
				}
			}
			.frame(maxWidth: .infinity)
			.if({true}, { view in
				if #available(iOS 14.0, *) {
					view
					.navigationTitle("LetSee")

				} else {
					view
						.navigationBarTitle(Text("LetSee")
							.font(.headline.weight(.heavy)))
				}
			})
		}
		.navigationViewStyle(.stack)
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		let letSee = LetSee()
		let _ = letSee.handle(request: URLRequest(url: URL(string: "https://www.google.com")!), useMocks: Me.mocks)

		LetSeeView(letSee: letSee)
	}
}
