//
//  ContentView.swift
//  LetSeeExample
//
//  Created by Farshad Macbook M1 Pro on 4/21/22.
//

import SwiftUI
import Combine
import LetSee
struct ContentView: View {
	let apiManager = APIManager()
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	
	var body: some View {
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
			.navigationTitle("LetSee")
		}
		.navigationViewStyle(.stack)
		.onReceive(timer) { input in
			guard input.hashValue % 5 == 0 else {
				return
			}
			apiManager.sampleRequest(request: .randomRequest)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
