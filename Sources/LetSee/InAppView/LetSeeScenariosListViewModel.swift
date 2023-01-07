//
//  LetSeeScenariosListViewModel.swift
//  
//
//  Created by Farshad Jahanmanesh on 06/01/2023.
//

import Combine
import LetSeeCore
public final class LetSeeScenariosListViewModel: ObservableObject {
    private unowned var interceptor: RequestInterceptor

    let scenarios: Array<Scenario>
    @Published var selectedScenario: Scenario? = nil
    func toggleScenario(_ scenario: Scenario) {
        if self.interceptor.isScenarioActive, selectedScenario == scenario {
            self.interceptor.deactivateScenario()
            selectedScenario = nil
        } else {
            self.interceptor.activateScenario(scenario)
            selectedScenario = scenario
        }
    }

    public init(scenarios: LetSeeScenarios, interceptor: RequestInterceptor) {
        self.scenarios = scenarios.map({Scenario(name: $0.key, mocks: Array($0.value))})
        self.interceptor = interceptor
        self.selectedScenario = interceptor.scenario
    }
}
