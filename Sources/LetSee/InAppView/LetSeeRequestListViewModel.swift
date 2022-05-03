//
//  LetSeeRequestListViewModel.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
public final class LetSeeRequestsListViewModel: ObservableObject {
	unowned var interceptor: RequestInterceptor
	private var bag: [AnyCancellable] = []
	@Published var requestList: [LetSeeUrlRequest] = []
	func response(request: URLRequest, _ response: LetSeeMock) {
		switch response {
		case .failure(_, let error, let json):
			self.interceptor.respond(request: request, with: .failure(LetSeeError(error: error, data: json.data(using: .utf8))))
		case .error(_, let error):
			self.interceptor.respond(request: request, with: .failure(LetSeeError(error: error, data: nil)))
		case .success(_, let res, let jSON):
			self.interceptor.respond(request: request, with: .success((HTTPURLResponse(url: URL(string: "www.letsee.com")!, statusCode: res?.stateCode ?? 200, httpVersion: nil, headerFields: res?.header), jSON.data(using: .utf8)!)))
		case .live:
			self.interceptor.respond(request: request)
		case .cancel:
			self.interceptor.cancel(request: request)
		}
	}
	public init(interceptor: RequestInterceptor) {
		self.interceptor = interceptor
		interceptor.requestQueue
			.receive(on: DispatchQueue.main)
			.sink {[weak self] list in
				self?.requestList = list
					.reversed()
					.filter({$0.status == .idle})
			}
			.store(in: &bag)
	}
}
