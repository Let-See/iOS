//
//  LetSeeRequestListViewModel.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
import LetSee
public final class LetSeeRequestsListViewModel: ObservableObject {
	private unowned var interceptor: RequestInterceptor
	private var bag: [AnyCancellable] = []
    @Published var requestList: [LetSeeUrlRequest] = []
	func response(request: URLRequest, _ response: LetSeeMock) {
        interceptor.respond(request: request, with: response)
	}
    public init(interceptor: RequestInterceptor) {
		self.interceptor = interceptor
		interceptor.requestQueue
			.receive(on: DispatchQueue.main)
			.sink {[weak self] list in
                guard let self else {return}
				self.requestList = list
					.reversed()
					.filter({$0.status == .idle})
			}
			.store(in: &bag)
	}
}
