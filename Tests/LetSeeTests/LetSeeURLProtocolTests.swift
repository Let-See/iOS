//
//  LetSeeURLProtocol.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import Foundation
import XCTest
@testable import LetSeeCore

public struct Me {
	public let name: String
	public let family: String
	public init(
		name: String,
		family: String) {
			self.name = name
			self.family = family

		}
}

extension Me: LetSeeMockProviding {
	public static var mocks: Set<LetSeeMock> {
		[
			.defaultSuccess(name: "Normal User", data:
"""
{
 'name':'Farshad',
 'family': 'Jahanmanesh'
}
"""
					),

				.defaultFailure(name: "User Not Found", data:
"""
{
 'message':'User not found.'
}
"""
						),

				.defaultFailure(name: "User is Not Active", data:
"""
{
 'message':'User is Not Active.'
   }
"""
						),

				.defaultSuccess(name: "Admin User", data:
"""
{
  'name':'Farshad',
  'family': 'Jahanmanesh'
   }
"""
						),
		]
	}
}

final class LetSeeURLProtocolTest: XCTestCase {
	var letSee: LetSee!
	var session: URLSession!
	override func setUpWithError() throws {
        letSee = LetSee(mocksDirectoryName: "", on: .main)
		let configuration = URLSessionConfiguration.ephemeral
		LetSeeURLProtocol.letSee = letSee.interceptor
		configuration.protocolClasses = [LetSeeURLProtocol.self]
		session = URLSession(configuration: configuration)
	}

	override func tearDownWithError() throws {
		letSee = nil
		session = nil
	}

	func testAddingRequest() {
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.interceptor.intercept(request: url, availableMocks: Me.mocks)
		XCTAssertNotNil(letSee.interceptor.indexOf(request: url))
	}

	func testSuccessResponseARequest() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.interceptor.intercept(request: url, availableMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		if case let .success(_,  response,  data) = LetSeeMock.defaultSuccess(name: "", data: "") {
			letSee.interceptor.respond(request: url, with: .success((response?.asURLResponse, data.data(using: .utf8))))
		}

		wait(for: [waitForResponse], timeout: 10)
	}

	func testRemoveRequestAfterResponse() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.interceptor.intercept(request: url, availableMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			guard let _ = data else {
				return
			}
			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		if case let .success(_,  response,  data) = LetSeeMock.defaultSuccess(name: "", data: "") {
			letSee.interceptor.respond(request: url, with: .success((response?.asURLResponse, data.data(using: .utf8))))
		}
		sleep(1)
		let index = letSee.interceptor.indexOf(request: url)
		XCTAssertNil(index)
		wait(for: [waitForResponse], timeout: 10)
	}

	func testErrorResponseARequest() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.interceptor.intercept(request: url, availableMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			guard let _ = error else {
				return
			}

			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		letSee.interceptor.respond(request: url, with: .failure(LetSeeError(error: .badServerResponse, data: nil)))
		wait(for: [waitForResponse], timeout: 10)
	}
}
