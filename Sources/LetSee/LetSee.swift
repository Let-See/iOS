import Foundation
public typealias LetSeeUrlRequest = (request: URLRequest, mocks: [LetSeeMock]?, response: ((Result<Data, Error>)->Void)?)
final public class LetSee: ObservableObject {
	public private(set) var webServer: WebServer
	public var mockResponse: Bool = false
	@Published private(set) public var requestList: [LetSeeUrlRequest] = []

	/// logger address, you can open this address in your device browser to see the LetSee web application
	public var address: String {
		"http://\(webServer.loggerAddress)"
	}

	public init(_ baseUrl: String = "") {
		self.webServer = .init(apiBaseUrl: baseUrl)
	}

	/// we add an id to headers of the request. this id helps LetSee to find the pending request easly
	public func makeIdentifiable(request: URLRequest) -> URLRequest {
		request.addLetSeeID()
	}

	public func handle(request: URLRequest, useMocks mocks: [LetSeeMock]?) {
		self.requestList.append((request, mocks, nil))
	}

	public func updateResult(request: URLRequest, cb: ((Result<Data, Error>)->Void)?) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		var item = self.requestList[index]
		item.response = cb
		self.requestList[index] = item
	}

	public func response(request: URLRequest, with result: Result<Data, Error>) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.requestList[index].response?(result)
	}

	public func indexOf(request: URLRequest) -> Int? {
		self.requestList.firstIndex(where: {$0.0.url == request.url})
	}

	public func remove(request: URLRequest) {
		guard let index = self.indexOf(request: request) else {
			return
		}
		self.requestList.remove(at: index)
	}

	@discardableResult
	public func log(_ log: WebServer.Log) -> JSON? {
		return self.webServer.log(log)
	}

}

extension LetSee {
	static let headerKey: String = "LETSEE-LOGGER-ID"
}
