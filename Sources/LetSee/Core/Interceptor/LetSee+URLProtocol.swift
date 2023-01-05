//
//  LetSee+URLProtocol.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/1/22.
//

import Foundation

public final class LetSeeURLProtocol: URLProtocol {
	public static unowned var letSee: RequestInterceptor!
	public override class func canonicalRequest(for request: URLRequest) -> URLRequest {
		var _request = request
		_request.timeoutInterval = 3600
		return _request
	}
	
	public override class func canInit(with request: URLRequest) -> Bool {
        LetSee.shared.configuration.isMockEnabled
	}

	public override func startLoading() {
		let client = self.client
		Self.letSee.prepare(request: self.request, resultHandler: {[weak self] result in
			guard let self = self else {return}
			switch result {
			case .success((let response, let data)):
				client?.urlProtocol(self, didReceive: response!, cacheStoragePolicy: .notAllowed)
				client?.urlProtocol(self, didLoad: data!)
			case .failure(let error):
				client?.urlProtocol(self, didFailWithError: error.error)
			}
			client?.urlProtocolDidFinishLoading(self)
		})
	}

	public override func stopLoading() {
		Self.letSee.finish(request: self.request)
	}
}
