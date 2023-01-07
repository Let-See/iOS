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
                            makeScenarioRow(item)
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
        }, label: {
            VStack(alignment: .leading) {
                if let item = self.viewModel.selectedScenario, !isScenariosCollapsed {
                    DisclosureGroupTitleView(string: "Scenarios", showDivider: false)
                    makeScenarioRow(item)
                    Divider()
                } else {
                    DisclosureGroupTitleView(string: "Scenarios")
                }
            }
        })
    }

    @ViewBuilder
    func makeScenarioRow(_ item: Scenario) -> some View{
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: item == self.viewModel.selectedScenario ? "s.square.fill" : "s.square")
                    .foregroundColor(.black)
                Text(item.name)
                    .font(.subheadline)
                    .foregroundColor((colorScheme == .dark ? Color.white : Color.black).opacity(0.7))
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            if item == self.viewModel.selectedScenario, let currentStep = item.currentStep {
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
