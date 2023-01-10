//
//  APIService.swift
//  APIService
//
//  Created by Karin Prater on 20.08.21.
//

import Foundation
import SwiftUI
import LetSee

#if DEBUG
let letSee = LetSee("https://api.thecatapi.com/")
#endif

struct APIService: APIServiceProtocol {
	func fetchBreeds(url: URL?, completion: @escaping(Result<[Breed], APIError>) -> Void) {
		guard let url = url else {
			let error = APIError.badURL
			completion(Result.failure(error))
			return
		}
		let request = URLRequest(url: url)
		let completionHandler: ((Data?, URLResponse?, Error?) -> Void) = {(data , response, error) in
			if let error = error as? URLError {
				completion(Result.failure(APIError.url(error)))
			} else if let response = response as? HTTPURLResponse, !(200...299).contains(response.statusCode) {
				completion(Result.failure(APIError.badResponse(statusCode: response.statusCode)))
			} else if let data = data {
				let decoder = JSONDecoder()
				do {
					let breeds = try decoder.decode([Breed].self, from: data)
					completion(Result.success(breeds))

				}catch {
					completion(Result.failure(APIError.parsing(error as? DecodingError)))
				}
			}
		}

		let task: URLSessionDataTask
		#if RELEASE
			task = URLSession.shared.runDataTask(with: request, completionHandler: completionHandler)
		#else
			task = letSee.runDataTask(with: request, completionHandler: completionHandler, availableMocks: Breed.mocks)
		#endif

		task.resume()
	}
}
