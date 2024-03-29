//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
import LetSee

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
    @State private var isSettingCollapsed: Bool = false

    public init(viewModel: LetSeeViewModel) {
        self.viewModel = viewModel
        self.interceptor = LetSee.shared.interceptor
    }

    public var body: some View {
        NavigationView {
            ScrollView{
                VStack(spacing: 16) {
                    Toggle(isOn: self.$viewModel.configs.isMockEnabled) {
                        Text(self.viewModel.configs.isMockEnabled ? "Stop Mocking" : "Start Mocking")
                            .font(.body.bold())
                    }
                    .padding(.trailing)
                    Divider()
                    DisclosureGroup(isExpanded: $isSettingCollapsed, content: {
                        Toggle(isOn: self.$viewModel.configs.shouldCutBaseURLFromURLsTitle) {
                            VStack(alignment: .leading) {
                                Text("Cut the BaseURL from URLs title")
                                    .font(.footnote.bold())
                                Text(viewModel.configs.baseURL.absoluteString)
                                        .font(.caption)

                            }
                        }
                        .padding(.trailing)

                    }, label: {
                        DisclosureGroupTitleView(string: "Settings")
                    })

                    if viewModel.configs.isMockEnabled {
                        ScenariosListView(viewModel: .init(scenarios: LetSee.shared.scenarios, interceptor: interceptor))
                    }

                    RequestsListView(viewModel: .init(interceptor: interceptor))
                        .frame(maxWidth: .infinity)
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 8)
            .padding(.horizontal)
            .if({true}, { view in
                view
                    .navigationTitle("LetSee")

            })
                .navigationViewStyle(.stack)
                .environment(\.letSeeConfiguration, viewModel.configs)
        }
    }
}
#if DEBUG
struct LetSeePreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        LetSeeView(viewModel: .init())
    }
}
#endif
