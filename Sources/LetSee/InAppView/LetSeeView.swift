//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine

public struct LetSeeView: View {
	private unowned var letSee: LetSee
	private unowned var interceptor: RequestInterceptor
	@State private var isMockEnabled: Bool = false
	public init(letSee: LetSee) {
		self.letSee = letSee
		self.interceptor = letSee
	}
	public var body: some View {
		NavigationView {
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
					Toggle(isOn: self.$isMockEnabled) {
						Text("Mock Requests")
					}
					.padding()
					
					RequestsListView(viewModel: .init(interceptor: interceptor, isMockingEnabled: isMockEnabled))
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
			.navigationViewStyle(.stack)
			.onChange(of: self.isMockEnabled) { newValue in
				if newValue {
					self.interceptor.activateMocking()
				} else {
					self.interceptor.deactivateMocking()
				}
			}
		}
	}
}

//struct ContentView_Previews: PreviewProvider {
//	static var previews: some View {
//		let letSee = LetSee()
//		let _ = letSee.handle(request: URLRequest(url: URL(string: "https://www.google.com")!), useMocks: Me.mocks)
//
//		LetSeeView(letSee: letSee)
//	}
//}
