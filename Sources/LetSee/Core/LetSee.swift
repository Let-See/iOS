import Foundation

public typealias LetSeeUrlRequest = (request: URLRequest, mocks: Array<LetSeeMock>?, response: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?, status: LetSeeRequestStatus)
/// Adds @LETSEE>  at the beging of the print statement
///
/// - Parameters:
///    - message: the print string
internal func print(_ message: String) {
	Swift.print("@LETSEE > ", message)
}


final public class LetSee: ObservableObject {
	@Published private var _requestQueue: [LetSeeUrlRequest] = []
	public private(set) var webServer: WebServer
	private var _isMockingEnabled: Bool = false {
		didSet {
			guard !_isMockingEnabled else {return}
			// If mocking gets disabled, LetSee sends all queued request to the server to answer and dequeue all pending requests.
			_requestQueue.forEach {[weak self] request in
				self?.respond(request: request.request)
			}
		}
	}

	/// logger address, you can open this address in your device browser to see the LetSee web application
	public var address: String {
		"http://\(webServer.loggerAddress)"
	}

	public init(_ baseUrl: String = "") {
		self.webServer = WebServer(apiBaseUrl: baseUrl)
	}

	/// we add an id to headers of the request. this id helps LetSee to find the pending request easly
	public func makeIdentifiable(request: URLRequest) -> URLRequest {
		request.addLetSeeID()
	}

	public func indexOf(request: URLRequest) -> Int? {
		self._requestQueue.firstIndex(where: {$0.0.url == request.url})
	}

	@discardableResult
	public func log(_ log: WebServer.Log) -> JSON? {
		return self.webServer.log(log)
	}

}

extension LetSee {
	static let headerKey: String = "LETSEE-LOGGER-ID"

	public var sessionConfiguration: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.ephemeral
		LetSeeURLProtocol.letSee = self
		configuration.timeoutIntervalForRequest = 3600
		configuration.timeoutIntervalForResource = 3600
		configuration.protocolClasses = [LetSeeURLProtocol.self]
		return configuration
	}

	public func addLetSeeProtocol(to config : URLSessionConfiguration) -> URLSessionConfiguration {
		LetSeeURLProtocol.letSee = self
		config.protocolClasses = [LetSeeURLProtocol.self] + (config.protocolClasses ?? [])
		return config
	}

}

extension LetSee: RequestInterceptor {
	public var isMockingEnabled: Bool {
		self._isMockingEnabled
	}

	public func activateMocking() {
		defer {print("mocking activated.")}
		self._isMockingEnabled = true
	}

	public func deactivateMocking() {
		defer {print("mocking deactivated.")}
		self._isMockingEnabled = false
	}

	public var requestQueue: Published<[LetSeeUrlRequest]>.Publisher {
		self.$_requestQueue
	}

	public func intercept(request: URLRequest, availableMocks mocks: Set<LetSeeMock> = []) {
		let mocks = mocks.union([
			.live,
			.cancel])
			.sorted() + [.defaultSuccess(name: "Custom Success", data: "{}"),
						 .defaultFailure(name: "Custom Failure", data: "{}")]

		self._requestQueue.append((request, mocks, nil, .idle))
	}

	public func prepare(request: URLRequest, resultHandler: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		var item = self._requestQueue[index]
		item.response = resultHandler
		self._requestQueue[index] = item
	}

	public func respond(request: URLRequest, with result: Result<LetSeeSuccessResponse, LetSeeError>) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.update(request: request, status: .loading)
		self._requestQueue[index].response?(result)
	}

	public func update(request: URLRequest, status: LetSeeRequestStatus) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		var item = self._requestQueue[index]
		item.status = status
		self._requestQueue[index] = item
	}

	public func respond(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.update(request: request, status: .loading)
		URLSession.shared.dataTask(with: self._requestQueue[index].request) {[weak self] data, response, error in
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
		.resume()
	}

	public func cancel(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.update(request: request, status: .loading)
		self._requestQueue[index].response?(.failure(LetSeeError(error: URLError.cancelled, data: nil)))
	}

	public func finish(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self._requestQueue.remove(at: index)
	}
}
