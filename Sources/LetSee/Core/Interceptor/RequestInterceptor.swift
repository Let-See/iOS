//
//  RequestInterceptor.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation

public protocol RequestInterceptor: AnyObject {
	var isMockingEnabled: Bool {get}
	func activateMocking()
	func deactivateMocking()
	/// Queued requests
	var requestQueue: Published<[LetSeeUrlRequest]>.Publisher {get}

	/// intercepts and queued a request. this requests will be remained in the queue until user selects a response for it
	///
	/// - Parameter request: a url request.
	/// - Parameter availableMocks: mocks objects, these mocks will be provided to the user and she can select one of these mocks to answer the requests with them. All requests have two default mocks, **`Live Request`, `Error (400)`**
	///
	func intercept(request: URLRequest, availableMocks mocks: Set<LetSeeMock>)

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

	/// Changes the request status
	func update(request: URLRequest, status: LetSeeRequestStatus)

	/// it should be called when the request got it response and finished the processing it, this function cleans up the request from the queue.
	func finish(request: URLRequest)
}
