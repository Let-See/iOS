//
//  ScenarioProcessing.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
protocol ScenarioProcessing: DirectoryProcessing where Information == FileInformation {
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]>
    func buildScenarios(for path: String, using mocks:Dictionary<String, Set<LetSeeMock>>) throws -> [Scenario]
}
