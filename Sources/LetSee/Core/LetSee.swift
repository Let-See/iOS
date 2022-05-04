import Foundation

public typealias LetSeeUrlRequest = (request: URLRequest, mocks: Array<LetSeeMock>?, response: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?, status: LetSeeRequestStatus)
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
