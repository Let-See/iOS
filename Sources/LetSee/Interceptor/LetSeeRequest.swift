//
//  LetSeeRequest.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/4/22.
//

import Foundation

protocol LetSeeRequest: AnyObject {
	var request: URLRequest{get}
	var mocks: [LetSeeMock]{get set}
	var id: String {get set}
}

extension LetSeeRequest {
	func makeIdentifiable() -> Self {
		self.id = UUID().uuidString
		return self
	}
}
