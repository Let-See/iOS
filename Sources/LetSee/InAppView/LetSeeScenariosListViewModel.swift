//
//  LetSeeScenariosListViewModel.swift
//  
//
//  Created by Farshad Jahanmanesh on 06/01/2023.
//

import Combine
import LetSee
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

    public init(scenarios: [Scenario], interceptor: RequestInterceptor) {
        self.scenarios = scenarios
        self.interceptor = interceptor
        
        interceptor.scenario
            .assign(to: &$selectedScenario)
    }
}
