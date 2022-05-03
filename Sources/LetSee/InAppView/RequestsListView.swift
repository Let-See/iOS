//
//  LetSeeViewModel.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine

public struct RequestsListView: View {
	@ObservedObject private var viewModel: LetSeeRequestsListViewModel
	public init(viewModel: LetSeeRequestsListViewModel) {
		self.viewModel = viewModel
	}
	public var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			HStack(spacing: 24){
				Text("Requests List")
					.font(.headline.weight(.heavy))

				if #available(iOS 14.0, *) {
					ProgressView()
				} else {
					ActivityIndicatorView(isAnimating: .constant(true), style: .medium)
				}
			}
			if !self.viewModel.requestList.isEmpty {
				ForEach(self.viewModel.requestList, id: \.request) { request in
					NavigationLink {
						MocksListView(tap: {mock in
							self.viewModel.response(request: request.request, mock)
						}, request: request)
					} label: {
						HStack {
							Image(systemName: "link.circle.fill")
								.foregroundColor(.gray)
							Text(request.request.url?.absoluteString ?? "")
								.font(.subheadline)
								.foregroundColor(.black.opacity(0.7))
								.multilineTextAlignment(.leading)
							Spacer()
							Image(systemName: "chevron.right")
								.foregroundColor(.gray)
						}
					}
					Divider()
				}

			} else {
				Spacer()
				Text("No Request Received Yet.")
					.font(.subheadline)
					.foregroundColor(.black)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
				Spacer()
			}
		}
		.frame(maxWidth: .infinity, alignment: .leading)
	}
}

//struct SwiftUIView_Previews: PreviewProvider {
//	
//	static var previews: some View {
//		let letSee = LetSee()
//		let _ = letSee.handle(request: URLRequest(url: URL(string: "https://www.google.com")!), useMocks: Me.mocks)
//		RequestsListView(viewModel: .init(letSee: letSee))
//		MocksListView(tap: { _ in
//
//		}, request: (URLRequest(url: URL(string: "https://www.google.com")!), Me.mocks, nil))
//
//		JsonViewerView(tap: { _ in
//
//		}, mock: Me.mocks.first!)
//	}
//}
