//
//  DefaultScenarioProcessor.swift
//  
//
//  Created by Farshad Jahanmanesh on 14/01/2023.
//

import Foundation
struct DefaultScenarioProcessor: ScenarioProcessing {
    func buildScenarios(for path: String, using mocks:Dictionary<String, Set<LetSeeMock>>) throws -> [Scenario] {
        try self.process(path)
            .flatMap({$0.value})
            .reduce(into: []) { partialResult, files in
                guard let scenarioData = try? Data(contentsOf: files.filePath),
                      let scenarioFileInformation: ScenarioFileInformation = try? PropertyListDecoder().decode(ScenarioFileInformation.self, from: scenarioData)
                else {
                    return
                }
                scenarioFileInformation.steps.forEach { item in
//                    self.process(item.folder)
                }
                print(scenarioFileInformation)
//                partialResult.append(.init(from: scenario, availableMocks: self.mocks, fileToMockMapper: self.fileToMockMapper, fileName: fileName))
            }
        return []
    }
    
    private let _process: (String) throws -> Dictionary<DirectoryRequestPath, [Self.Information]>
    private let scenarioDecoder: PropertyListDecoder
    private let requestToMockMapper: RequestToMockMapper
    
    init<DS>(directoryProcessor: DS = FileDirectoryProcessor(),
             scenarioDecoder: PropertyListDecoder = PropertyListDecoder(),
             requestToMockMapper: @escaping RequestToMockMapper = DefaultRequestToMockMapper.transform
    )
    where DS: DirectoryProcessing, DS.Information == Self.Information {
        self._process = directoryProcessor.process
        self.scenarioDecoder = scenarioDecoder
        self.requestToMockMapper = requestToMockMapper
    }
    func process(_ path: String) throws -> Dictionary<DirectoryRequestPath, [FileInformation]> {
        try _process(path)
    }
}
