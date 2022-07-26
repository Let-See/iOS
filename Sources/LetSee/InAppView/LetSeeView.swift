//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
#if SWIFT_PACKAGE
import Letsee_Core
#endif
public struct LetSeeView: View {
	private unowned var letSee: LetSee
	private unowned var interceptor: RequestInterceptor
	@State private var isMockEnabled: Bool = false
	public init(letSee: LetSee) {
		self.letSee = letSee
		self.interceptor = letSee.interceptor
		self.isMockEnabled = interceptor.isMockingEnabled
	}
	public var body: some View {
		NavigationView {
			ScrollView{
				VStack(spacing: 16){
					Spacer()
					Text("Server Address. you can open this address in your machine to see the logs")
						.font(.subheadline)
					HStack {
						Text("\(letSee.address)")
							.font(.headline)
							.frame(maxWidth: .infinity, alignment: .leading)

						Button("copy") {
							// write to clipboard
							UIPasteboard.general.string = letSee.address
						}
					}
					.padding()
					Toggle(isOn: self.$isMockEnabled) {
						Text("Mock Requests")
					}
					.padding()
					
					RequestsListView(viewModel: .init(interceptor: interceptor, isMockingEnabled: isMockEnabled))
						.frame(maxWidth: .infinity)
						.padding()
					Spacer()
				}
			}
			.frame(maxWidth: .infinity)
			.if({true}, { view in
				if #available(iOS 14.0, *) {
					view
						.navigationTitle("LetSee")

				} else {
					view
						.navigationBarTitle(Text("LetSee")
							.font(.headline.weight(.heavy)))
				}
			})
			.navigationViewStyle(.stack)
			.onDataChange(of: self.isMockEnabled, perform: { newValue in
				if newValue {
					self.interceptor.activateMocking()
				} else {
					self.interceptor.deactivateMocking()
				}
			})
				.onAppear {
				self.isMockEnabled = interceptor.isMockingEnabled
			}
		}
	}
}

struct ChangeObserver<Content: View, Value: Equatable>: View {
	let content: Content
	let value: Value
	let action: (Value) -> Void

	init(value: Value, action: @escaping (Value) -> Void, content: @escaping () -> Content) {
		self.value = value
		self.action = action
		self.content = content()
		_oldValue = State(initialValue: value)
	}

	@State private var oldValue: Value

	var body: some View {
		if oldValue != value {
			DispatchQueue.main.async {
				oldValue = value
				self.action(self.value)
			}
		}
		return content
	}
}

extension View {
	func onDataChange<Value: Equatable>(of value: Value, perform action: @escaping (_ newValue: Value) -> Void) -> some View {
		Group {
			if #available(iOS 14.0, macOS 11.0, tvOS 14.0, watchOS 7.0, *) {
				self.onChange(of: value, perform: action)
			} else {
				ChangeObserver(value: value, action: action) {
					self
				}
			}
		}
	}
}
