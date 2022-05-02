//
//  LetSeeURLProtocol.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import Foundation
import XCTest
@testable import LetSee
final class LetSeeURLProtocolTest: XCTestCase {
	var letSee: LetSee!
	var session: URLSession!
	override func setUpWithError() throws {
		letSee = LetSee()
		let configuration = URLSessionConfiguration.ephemeral
		LetSeeURLProtocol.letSee = letSee
		configuration.protocolClasses = [LetSeeURLProtocol.self]
		session = URLSession(configuration: configuration)
	}

	override func tearDownWithError() throws {
		letSee = nil
		session = nil
	}

	func testAddingRequest() {
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.handle(request: url, useMocks: Me.mocks)
		XCTAssertNotNil(letSee.indexOf(request: url))
	}

	func testAttachResponseToRequest() {
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.handle(request: url, useMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
		}
		.resume()
		sleep(1)
		let index = letSee.indexOf(request: url)
		XCTAssertNotNil(index)
		XCTAssertNotNil(letSee.requestList[index!].response)
	}

	func testSuccessResponseARequest() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.handle(request: url, useMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		letSee.response(request: url, with: .success(Me.mocks.first!.data()!))
		wait(for: [waitForResponse], timeout: 10)
	}

	func testRemoveRequestAfterResponse() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.handle(request: url, useMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			guard let _ = data else {
				return
			}
			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		letSee.response(request: url, with: .success(Me.mocks.first!.data()!))
		sleep(1)
		let index = letSee.indexOf(request: url)
		XCTAssertNil(index)
		wait(for: [waitForResponse], timeout: 10)
	}

	func testErrorResponseARequest() {
		let waitForResponse = expectation(description: "Wait For Response")
		let url = URLRequest(url: URL(string: "https://google.com")!)
		letSee.handle(request: url, useMocks: Me.mocks)
		session.dataTask(with: url) { data, response, error in
			guard let _ = error else {
				return
			}

			waitForResponse.fulfill()
		}
		.resume()
		sleep(1)
		letSee.response(request: url, with: .failure(URLError(.badServerResponse)))
		wait(for: [waitForResponse], timeout: 10)
	}
}
