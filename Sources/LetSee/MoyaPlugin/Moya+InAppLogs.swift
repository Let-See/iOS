//
//  Moya+InAppLogs.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

#if canImport(Moya)
import Foundation
import Moya

/// a plug to automate whole usage of LetSee library
///
/// - How to use?
///     - ......
///     - `provider = MoyaProvider<Apis>(plugins:[LetSeeInAppLogs(interceptor: interceptor)])`
///     - ......
///
/// and now just look at your console for the server ip address. you can filter the console by '@LETSEE>' if there are alot of lines in your console.
public final class LetSeeInAppLogs: PluginType {
	unowned let interceptor: RequestInterceptor

	/// - Paramters:
	///     - baseUrl: an optional text. this is just a text which `LetSee` uses it in the HTML page.
	public init(interceptor: RequestInterceptor) {
		self.interceptor = interceptor
	}

	/// we add an id to headers of the request. this id helps us to find the pending request (this request) easly
	public func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
		var request = request.addLetSeeID()
		interceptor.intercept(request: request, availableMocks: ((target as? LetSeeMockProviding)?.mocks) ?? [])
		return request
	}

	public func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
		var request: URLRequest?
		switch result {
		case.success(let response):
			request = response.request

		case .failure(let error):
			request = error.response?.request
		}
		guard let request = request else {return}
		interceptor.finish(request: request)
	}

}
#endif

