//
//  DefaultScenarioProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct DefaultScenarioProcessor: ScenarioProcessing {
    func buildScenarios(for path: String,
                        requestToMockMapper: (String) -> CategorisedMocks?,
                        globalConfigs: GlobalMockDirectoryConfig?) throws -> [Scenario] {
       return try self.process(path)
            .flatMap({$0.value})
            .reduce(into: []) { partialResult, scenarioFile in
                guard let scenarioData = try? Data(contentsOf: scenarioFile.filePath),
                      let scenarioFileInformation: ScenarioFileInformation = try? PropertyListDecoder().decode(ScenarioFileInformation.self, from: scenarioData)
                else {
                    return
                }
                var scenarioMocks: [LetSeeMock] =  []
                scenarioFileInformation.steps.forEach { item in
                    let overriddenPath = globalConfigs?.hasMap(for: item.folder)?.to
                    let mockKey = overriddenPath != nil ? overriddenPath! + item.folder : item.folder
                    guard let cleanedName = try? JSONFileNameParser().parse(.init(name: item.responseFileName, filePath: URL(string: "/api/")!, relativePath: "")),
                       let mocks = requestToMockMapper(mockKey),
                       let mock = mocks.mocks.first(where: {$0.name.caseInsensitiveCompare(cleanedName.displayName) == .orderedSame})
                    else {
                        return
                    }
                    // append the mock
                    scenarioMocks.append(mock)
                }
                let name = scenarioFile.name.replacingOccurrences(of: ".plist", with: "")
                partialResult.append(Scenario(name: name, mocks: scenarioMocks))
            }

    }
    
    private let _process: (String) throws -> Dictionary<DirectoryRequestPath, [Self.Information]>
    private let scenarioDecoder: PropertyListDecoder

    init<DS>(directoryProcessor: DS = FileDirectoryProcessor(),
             scenarioDecoder: PropertyListDecoder = PropertyListDecoder()
    )
    where DS: DirectoryProcessing, DS.Information == Self.Information {
        self._process = directoryProcessor.process
        self.scenarioDecoder = scenarioDecoder
    }
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [FileInformation]> {
        try _process(path)
    }
}
