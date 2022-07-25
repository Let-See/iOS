import Foundation

/// Adds @LETSEE>  at the beging of the print statement
///
/// - Parameters:
///    - message: the print string
internal func print(_ message: String) {
	Swift.print("@LETSEE > ", message)
}


final public class LetSee {
	public private(set) var webServer: WebServer

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

	@discardableResult
	public func log(_ log: WebServer.Log) -> JSON? {
		return self.webServer.log(log)
	}

}

extension LetSee {
	static let headerKey: String = "LETSEE-LOGGER-ID"
}

public extension LetSee {
	func runDataTask(using defaultSession: URLSession = URLSession.shared, with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
		let request = request.addLetSeeID()
		self.log(.request(request))
		let session: URLSession
		if let interceptor = self as? InterceptorContainer {
			let configuration = interceptor.addLetSeeProtocol(to: defaultSession.configuration)
			session = URLSession(configuration: configuration)
		} else {
			session = defaultSession
		}
		return session.dataTask(with: request, completionHandler: {[weak self](data , response, error) in
			if let error = error as? URLError {
				self?.log(.response(HTTPURLResponse(url: error.failingURL ?? URL(string: "https://www.letsee.com/")!, statusCode: error.errorCode, httpVersion: nil, headerFields: [:])!, forRequest: request, withBody: LetSeeError(error: error, data: data).data))
			}else if let response = response {
				self?.log(.response(response, forRequest: request, withBody: data))
			}
			completionHandler(data,response,error)
		})
	}
}

