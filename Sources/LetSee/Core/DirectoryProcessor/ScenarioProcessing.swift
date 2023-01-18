//
//  ScenarioProcessing.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
public protocol ScenarioProcessing: DirectoryProcessing where Information == FileInformation {
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [Information]>
    func buildScenarios(for path: String,
                        requestToMockMapper: (String) -> CategorisedMocks?,
                        globalConfigs: GlobalMockDirectoryConfig?) throws -> [Scenario]
}
