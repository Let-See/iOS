//
//  RequestInterceptor.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
/**
This protocol defines the behavior of a request interceptor. A request interceptor is responsible for intercepting and queuing requests, preparing requests for incoming results, and responding to requests.

Scenario:
A scenario represents a set of rules and data for handling requests. Scenarios can be activated and deactivated.

#### Properties

- `scenario`: A publisher for the current active scenario.
- `isScenarioActive`: A boolean value indicating whether a scenario is currently active.

#### Methods

- `activateScenario(_:)`: Activates a scenario.
- `deactivateScenario()`: Deactivates the current scenario.
- `intercept(request:availableMocks:)`: Intercepts and queues a request. The request will remain in the queue until the user selects a response for it.
- `prepare(request:resultHandler:)`: Prepares the request for the incoming result. The user can select a mock or live request, and the result handler will be called when the data is ready.
- `cancel(request:)`: Cancels the request. The request will be answered with an error.
- `respond(request:)`: Sends the request to the live server.
- `respond(request:with:)`: Answers the request with a result.
- `update(request:status:)`: Updates the status of the request.
- `finish(request:)`: Removes the request from the queue and cleans it up.
*/
public protocol RequestInterceptor: AnyObject {
    var scenario: Published<Scenario?>.Publisher {get}
    var isScenarioActive: Bool {get}
    func activateScenario(_ scenario: Scenario)
    func deactivateScenario()
	/// Queued requests
	var requestQueue: Published<[LetSeeUrlRequest]>.Publisher {get}

	/// intercepts and queued a request. this requests will be remained in the queue until user selects a response for it
	///
	/// - Parameter request: a url request.
	/// - Parameter availableMocks: mocks objects, these mocks will be provided to the user and she can select one of these mocks to answer the requests with them. All requests have two default mocks, **`Live Request`, `Error (400)`**
	///
	func intercept(request: URLRequest, availableMocks mocks: CategorisedMocks?)

	/// Prepares the request for the incoming result. the user selects a mock either a preprovided json or live request, when the result is ready, the requests will be notified by using the result handler
	///
	/// - Parameters:
	/// 	- request: the request, the function uses this request to find the queued request
	/// 	- resultHandler: this function will be called when the data is ready
	func prepare(request: URLRequest, resultHandler: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?)

	/// Cancels the request, the canceled request will be answered by an 400 error.
	func cancel(request: URLRequest)

	/// Sends the request to the live server
	func respond(request: URLRequest)

	/// Answers the request by a result
	func respond(request: URLRequest, with result: Result<LetSeeSuccessResponse, LetSeeError>)
    func respond(request: URLRequest, with response: LetSeeMock) 
	/// Changes the request status
	func update(request: URLRequest, status: LetSeeRequestStatus)

	/// it should be called when the request got it response and finished the processing it, this function cleans up the request from the queue.
	func finish(request: URLRequest)
    
}
