//
//  LetSeeViewModel.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
public final class LetSeeRequestListViewModel: ObservableObject {
	unowned var letSee: LetSee
	private var bag: [AnyCancellable] = []
	@Published var requestList: [LetSeeUrlRequest] = []
	func response(request: URLRequest, _ response: LetSeeMock) {
		switch response {
		case .failure(_, _):
			self.letSee.response(request: request, with: .failure(NSError(domain: "ds", code: 3)))
		case .success(_, let jSON):
			self.letSee.response(request: request, with: .success(jSON.data(using: .utf8)!))
		}
	}
	public init(letSee: LetSee) {
		self.letSee = letSee
		letSee.$requestList
			.receive(on: DispatchQueue.main)
			.sink {[weak self] list in
				self?.requestList = list
			}
			.store(in: &bag)
	}
}
