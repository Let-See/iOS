//
//  LetSee+InterceptorExtensions.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/4/22.
//

import Foundation
import Combine

/// This is the main class that manages the request interception and response handling in the
public final class LetSeeInterceptor: ObservableObject {

    /// A closure that is called whenever a request is added to the interceptor.
    public var onRequestAdded: ((URLRequest)-> Void)? = nil

    /// A closure that is called whenever a request is removed from the interceptor.
    public var onRequestRemoved: ((URLRequest)-> Void)? = nil

    /// The currently active scenario.
    @Published private(set) public var _scenario: Scenario?

    /// liveToServer is a function that is used to send a request to the server and retrieve a response. It takes a URLRequest as input and a completion block as an optional parameter.
    /// The completion block takes three parameters: Data?, URLResponse?, and Error?. The function returns void.
    public var liveToServer: ((_ request: URLRequest, _ completion: ((URLResponse?, Data?, Error?) -> Void)?) -> Void)?

    /// The queue of requests that have been intercepted.
	@Published private(set) public var _requestQueue: [LetSeeUrlRequest] = []

    /// The configurations for the `LetSee` instance.
    @Published var configurations: LetSee.Configuration = .default
}

extension LetSeeInterceptor: RequestInterceptor {
    /**
    The `scenario` property gets the current scenario in use, if there is no scenario active it returns `nil`.
    */
    public var scenario: Published<Scenario?>.Publisher {
        self.$_scenario
    }

    /**
    The `isScenarioActive` property gets a boolean value indicating whether there is a scenario active or not.
    */
    public var isScenarioActive: Bool {
        _scenario?.currentStep != nil
    }

    /**
    The `activateScenario(_:)` function activates a scenario.

    - Parameters:
      - scenario: The scenario to be activated.
    */
    public func activateScenario(_ scenario: Scenario) {
        self._scenario = scenario
    }

    /**
    The `deactivateScenario()` function deactivates the current scenario.
    */
    public func deactivateScenario() {
        self._scenario = nil
    }

    /**
    The `indexOf(request:)` function gets the index of a request in the queue.

    - Parameters:
      - request: The request to search for.

    - Returns: The index of the request in the queue if it exists, otherwise `nil`.
    */
	public func indexOf(request: URLRequest) -> Int? {
        self._requestQueue.firstIndex(where: {$0.request.url == request.url})
	}

    /**
    The `requestQueue` property gets the current queue of requests.
    */
	public var requestQueue: Published<[LetSeeUrlRequest]>.Publisher {
		self.$_requestQueue
	}

    /**
    The `respondUsingScenario(request:)` function responds to a request using the current scenario.

    - Parameters:
      - request: The request to be responded to.
    */
    private func respondUsingScenario(request: URLRequest) {
        guard let mock = _scenario?.currentStep else {
            return
        }
        respond(request: request, with: mock)
        _scenario?.nextStep()
        if  _scenario?.currentStep == nil {
            _scenario = nil
        }
    }

    /**
     Intercepts a given URL request and stores it in a queue for later processing.

     - Parameters:
       - request: The URL request to be intercepted.
       - mocks: An optional categorised list of mock data that can be used to respond to the request. If no mocks are provided, a default set of mock responses will be available (e.g. live, cancel, success, failure).
     */
	public func intercept(request: URLRequest, availableMocks mocks: CategorisedMocks?) {
		let mocks = appendSystemMocks(mocks)
        onRequestAdded?(request)
        self._requestQueue.append(.init(request: request, mocks: mocks,status: .idle))
	}

    /**
     Appends a default set of mock responses to the provided list of mocks.

     - Parameters:
       - mocks: An optional categorised list of mock data.

     - Returns: An array of categorised mocks, containing the provided mocks and the default set of mock responses.
    */
	private func appendSystemMocks(_ mocks: CategorisedMocks?) -> Array<CategorisedMocks> {
        let generalMocks = CategorisedMocks(category: .general,
                                            mocks: [.live,
                                                    .cancel,
													.defaultSuccess(name: "Custom Success", data: "{}".data(using: .utf8)!),
                                                    .defaultFailure(name: "Custom Failure", data: "{}".data(using: .utf8)!)])
        if let mocks {
            return [mocks, generalMocks]
        } else {
            return [generalMocks]
        }
	}

    /**
     Prepares a request in the queue for later processing.

     - Parameters:
       - request: The URL request to be prepared.
       - resultHandler: An optional closure that will be called when the request is responded to, with the result of the response.
    */
	public func prepare(request: URLRequest, resultHandler: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		var item = self._requestQueue[index]
		item.response = resultHandler
		self._requestQueue[index] = item
        if self.isScenarioActive {
            respondUsingScenario(request: request)
            return
        }
	}

    /**
     Responds to a request in the queue with the given mock response.

     - Parameters:
       - request: The URL request to be responded to.
       - response: The mock response to use for the request.
    */
    public func respond(request: URLRequest, with response: LetSeeMock) {
        switch response {
        case .failure(_, let error, let json):
            self.respond(request: request, with: .failure(LetSeeError(error: error, data: json)))
        case .error(_, let error):
            self.respond(request: request, with: .failure(LetSeeError(error: error, data: nil)))
        case .success(_, let res, let jSON):
            self.respond(request: request, with: .success((HTTPURLResponse(url: URL(string: "www.letsee.com")!, statusCode: res?.stateCode ?? 200, httpVersion: nil, headerFields: res?.header), jSON)))
        case .live:
            self.respond(request: request)
        case .cancel:
            self.cancel(request: request)
        }
    }

    /**
     Responds to a request in the queue with the given result.

     - Parameters:
       - request: The URL request to be responded to.
       - result: The result of the response, either a success or an error.
    */
	public func respond(request: URLRequest, with result: Result<LetSeeSuccessResponse, LetSeeError>) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.update(request: request, status: .loading)
		self._requestQueue[index].response?(result)
	}

    /**
      Updates the status of a given request in the request queue.

      - Parameters:
        - request: The request whose status needs to be updated.
        - status: The new status of the request.
     */
	public func update(request: URLRequest, status: LetSeeRequestStatus) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		var item = self._requestQueue[index]
		item.status = status
		self._requestQueue[index] = item
	}

    /**
      Makes a request live by sending it to the server.

      - Parameters:
        - request: The request that needs to be made live.
     */
	public func respond(request: URLRequest) {
        guard self.indexOf(request: request) != nil else {
			return
		}
		self.update(request: request, status: .loading)
        liveToServer?(request){[weak self] response, data, error in
			guard let self = self else {return}

			guard let index = self.indexOf(request: request) else {
				return
			}
			guard error == nil else {
				self.respond(request: self._requestQueue[index].request, with: .failure(.init(error: error!, data: data)))
				return
			}

			self._requestQueue[index].response?(.success((response, data)))
		}
	}

    /**
      Cancels a request.

      - Parameters:
        - request: The request that needs to be cancelled.
     */
	public func cancel(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.update(request: request, status: .loading)
		self._requestQueue[index].response?(.failure(LetSeeError(error: URLError.cancelled, data: nil)))
	}

    /**
      Removes a request from the request queue.

      - Parameters:
        - request: The request that needs to be removed.
     */
	public func finish(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self._requestQueue.remove(at: index)
        onRequestRemoved?(request)
	}
}
