//
//  LetSeeView.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/2/22.
//

import SwiftUI
import Combine
import LetSeeCore

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
                        Text("Mock Requests")
                            .font(.body.bold())
                    }
                    .padding(.trailing)
                    Divider()
                    DisclosureGroup(isExpanded: $isSettingCollapsed, content: {
                        Toggle(isOn: self.$viewModel.configs.shouldCutBaseURLFromURLsTitle) {
                            VStack(alignment: .leading) {
                                Text("Cut the BaseURL from URLs title")
                                    .font(.footnote.bold())
                                if let baseURL = viewModel.configs.baseURL{
                                    Text(baseURL)
                                        .font(.caption)
                                }
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
#if DEBUG
struct LetSeePreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
        LetSeeView(viewModel: .init())
    }
}
#endif
