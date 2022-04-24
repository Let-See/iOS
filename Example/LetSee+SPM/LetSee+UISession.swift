//
//  LetSee+UISession.swift
//  LetSee+SPM
//
//  Created by Farshad Macbook M1 Pro on 4/21/22.
//

import Foundation
import LetSee
let letSee = LetSee()
final class APIManager {
    func sampleRequest(request: URLRequest) {
        letSee.log(.request(request: request.addID()))
        mockSession.dataTask(with: request) { data, response, error in
            guard error == nil else {
                fatalError("here you have to do something, maybe internet connection is not available or any other fundamental errors")
            }
            
            guard let response = response else {
                return
            }

            // just for sample purpose to simulate the network latancy, you do not need to do this in your code
            sleep(UInt32(request.timeoutInterval))
            letSee.log(.response(request: request, response: response, body: data))
        }
        .resume()
    }
    init() {}
}

