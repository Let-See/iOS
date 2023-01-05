//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
import LetSeeCore

extension EnvironmentValues {
    var letSeeConfiguration: LetSee.Configuration {
        set {
            self[LetSeeConfigurationKey.self] = newValue
        }
        get {
            self[LetSeeConfigurationKey.self]
        }
    }
}
struct LetSeeConfigurationKey: EnvironmentKey {
    static let defaultValue: LetSee.Configuration = LetSee.shared.configuration
}
public class LetSeeViewModel: ObservableObject {
    @Published var configs: LetSee.Configuration = LetSee.shared.configuration {
        didSet {
            LetSee.shared.config(configs)
            LetSee.shared.onMockStateChanged?(configs.isMockEnabled)
        }
    }
}
public struct LetSeeView: View {
    @ObservedObject private var viewModel: LetSeeViewModel
    private unowned var interceptor: RequestInterceptor

    public init(viewModel: LetSeeViewModel) {
        self.viewModel = viewModel
        self.interceptor = LetSee.shared.interceptor
    }

    public var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 16){
                    Spacer()

                    VStack {
                        Toggle(isOn: self.$viewModel.configs.isMockEnabled) {
                            Text("Mock Requests")
                                .font(.body.bold())
                        }

                        Toggle(isOn: self.$viewModel.configs.shouldCutBaseURLFromURLsTitle) {
                            VStack(alignment: .leading) {
                                Text("Cut the BaseURL from URLs title")
                                    .font(.body.bold())
                                if let baseURL = viewModel.configs.baseURL{
                                    Text(baseURL)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    RequestsListView(viewModel: .init(interceptor: interceptor))
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
            .environment(\.letSeeConfiguration, viewModel.configs)
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
