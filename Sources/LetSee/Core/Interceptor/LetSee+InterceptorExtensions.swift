//
//  LetSee+InterceptorExtensions.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/4/22.
//

import Foundation
import Combine
public struct CategorisedMocks: Hashable {
    public var category: LetSeeMock.Category
    public var mocks: [LetSeeMock]
}
public struct LetSeeUrlRequest {
    public var request: URLRequest
    public var mocks: Array<CategorisedMocks>
    public var response: ((Result<LetSeeSuccessResponse, LetSeeError>)->Void)?
    public var status: LetSeeRequestStatus
    public func nameBuilder(cutBaseURL: Bool, baseURL: String?) -> String {
        guard let name = request.url?.absoluteString else {return ""}
        guard cutBaseURL, let baseURL else {return name}
        return name.lowercased().replacingOccurrences(of: baseURL, with: "")
    }
    public init(request: URLRequest, mocks: [CategorisedMocks]? = nil, response: ((Result<LetSeeSuccessResponse, LetSeeError>) -> Void)? = nil, status: LetSeeRequestStatus) {
        self.request = request
        self.mocks = mocks ?? []
        self.response = response
        self.status = status
    }
}
public extension LetSee {
	var sessionConfiguration: URLSessionConfiguration {
		let configuration = URLSessionConfiguration.ephemeral
		LetSeeURLProtocol.letSee = self.interceptor
		configuration.timeoutIntervalForRequest = 3600
		configuration.timeoutIntervalForResource = 3600
		configuration.protocolClasses = [LetSeeURLProtocol.self]
		return configuration
	}

	func addLetSeeProtocol(to config : URLSessionConfiguration) -> URLSessionConfiguration {
		LetSeeURLProtocol.letSee = self.interceptor
		config.protocolClasses = [LetSeeURLProtocol.self] + (config.protocolClasses ?? [])
		return config
	}

}

extension LetSee: InterceptorContainer {
	public var interceptor: LetSeeInterceptor {
		return LetSeeInterceptor.shared
	}
}

public final class LetSeeInterceptor: ObservableObject {
	private init() {}
    public var onRequestAdded: ((URLRequest)-> Void)? = nil
    public var onRequestRemoved: ((URLRequest)-> Void)? = nil

    public var liveToServer: LiveToServer?  = nil
	public static var shared: LetSeeInterceptor = .init()
	@Published private(set) public var _requestQueue: [LetSeeUrlRequest] = []
    @Published var configurations: LetSee.Configuration = .default
}

extension LetSeeInterceptor: RequestInterceptor {
	public func indexOf(request: URLRequest) -> Int? {
        self._requestQueue.firstIndex(where: {$0.request.url == request.url})
	}

	public var requestQueue: Published<[LetSeeUrlRequest]>.Publisher {
		self.$_requestQueue
	}

	public func intercept(request: URLRequest, availableMocks mocks: CategorisedMocks?) {
		let mocks = appendSystemMocks(mocks)
        onRequestAdded?(request)
        self._requestQueue.append(.init(request: request, mocks: mocks,status: .idle))
	}

	private func appendSystemMocks(_ mocks: CategorisedMocks?) -> Array<CategorisedMocks> {
        let generalMocks = CategorisedMocks(category: .general, mocks: [.live,
                                                         .cancel,
                                                         .defaultSuccess(name: "Custom Success", data: "{}"),
                                                         .defaultFailure(name: "Custom Failure", data: "{}")])
        if let mocks {
            return [mocks, generalMocks]
        } else {
            return [generalMocks]
        }
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
        guard self.indexOf(request: request) != nil else {
			return
		}
		self.update(request: request, status: .loading)
        liveToServer?(request){[weak self] data, response, error in
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
        onRequestRemoved?(request)
	}
}
