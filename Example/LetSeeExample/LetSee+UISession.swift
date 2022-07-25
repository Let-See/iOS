//
//  LetSee+UISession.swift
//  LetSee+CocoaPods
//
//  Created by Farshad Macbook M1 Pro on 4/21/22.
//

import Foundation
import LetSee
import Letsee_Interceptor
let letSee = LetSee()
final class APIManager {
    func sampleRequest(request: URLRequest) {
		// needs to add an id to this request because letsee will use this id to map the result to the request in frontend
//		letSee.interceptor.intercept(request: request, availableMocks: Me.mocks)
		letSee.runDataTask(using: URLSession.shared, with: request) { data, response, error in
            guard error == nil else {
                print("here you have to do something, maybe internet connection is not available or any other fundamental errors")
				return
            }
            
            guard let response = response else {
                return
            }

            // just for sample purpose to simulate the network latancy, you do not need to do this in your code
            letSee.log(.response(response, forRequest: request , withBody: data))
        }
        .resume()
    }
    init() {}
}

