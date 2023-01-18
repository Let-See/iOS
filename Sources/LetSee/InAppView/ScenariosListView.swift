//
//  ScenariosListView.swift
//  
//
//  Created by Farshad Jahanmanesh on 06/01/2023.
//

import SwiftUI
import Combine
import LetSee

struct ScenariosListView: View {
    @ObservedObject private var viewModel: LetSeeScenariosListViewModel
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.letSeeConfiguration) private var configs: LetSee.Configuration
    @State private var isScenariosCollapsed: Bool = false
    public init(viewModel: LetSeeScenariosListViewModel) {
        self.viewModel = viewModel
    }
    public var body: some View {
        DisclosureGroup(isExpanded: $isScenariosCollapsed, content: {
            ScrollView{
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 24){
                        if configs.isMockEnabled {
                            //                        ProgressView()
                        }
                    }
                    if !self.viewModel.scenarios.isEmpty {
                        ForEach(self.viewModel.scenarios, id: \.name) { item in
                            Button {
                                self.viewModel.toggleScenario(item)
                            } label: {
                                ScenarioRow(isSelected: .constant(item == viewModel.selectedScenario), scenario: item)
                            }

                            Divider()
                        }

                    } else {
                        Spacer()
                        Text("No Scenario is available.")
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }.frame(maxHeight: 300)
        }, label: {
            VStack(alignment: .leading) {
                if let selectedScenario = self.viewModel.selectedScenario, !isScenariosCollapsed {
                    DisclosureGroupTitleView(string: "Scenarios", showDivider: false)
                    ScenarioRow(isSelected: .constant(true), scenario: selectedScenario)
                    Divider()
                } else {
                    DisclosureGroupTitleView(string: "Scenarios")
                }
            }
        })
    }
}

struct ScenarioRow: View {
    @Binding private var isSelected: Bool
    @Environment(\.colorScheme) var colorScheme
    private var scenario: Scenario
    init(isSelected: Binding<Bool>, scenario: Scenario) {
        self._isSelected = isSelected
        self.scenario = scenario
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: isSelected ? "s.square.fill" : "s.square")
                    .foregroundColor(.black)
                Text(scenario.name)
                    .font(.subheadline)
                    .foregroundColor((colorScheme == .dark ? Color.white : Color.black).opacity(0.7))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if isSelected, let currentStep = scenario.currentStep {
                HStack(spacing: 8) {
                    Text("NextResponse:")
                        .font(.caption)
                    Text(currentStep.name)
                        .font(.caption.bold())
                }
            }
        }
    }
}

#if DEBUG
struct ScenarioRow_Previews: PreviewProvider {
    static var previews: some View {
        ScenarioRow(isSelected: .constant(true), scenario: .init(name: "Salam", mocks: [.live]))
    }
}
#endif
