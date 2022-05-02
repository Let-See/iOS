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
		LetSeeView(letSee: letSee)
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
