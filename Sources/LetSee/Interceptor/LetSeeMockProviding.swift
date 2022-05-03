//
//  LetSeeMockProviding.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
public protocol LetSeeMockProviding {
	static var mocks:Set<LetSeeMock> {get}
	var mocks:Set<LetSeeMock> {get}
}

public extension LetSeeMockProviding {
	static var mocks: Set<LetSeeMock> {[]}
	var mocks: Set<LetSeeMock> {[]}
}
