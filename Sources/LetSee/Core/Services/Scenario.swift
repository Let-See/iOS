//
//  Scenario.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation
/// A Scenario is a combination of multiple mock data, each scenario has a name and a list of mock data. Scenarios are good to automate responding
/// to requests like when we want to test a specific flow, if there is an active scenario all the requests will be responded by using the scenarios mocks one by one, when there are no other mock in scenario, the scenario will be deactivate automatically
/// and the request will be suspended until you choose a response for them.
///
public struct Scenario: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.name == rhs.name && rhs.mocks == lhs.mocks
    }
    public let name: String
    public let mocks: [LetSeeMock]
    public init(name: String, mocks: [LetSeeMock]) {
        self.name = name
        self.mocks = mocks
    }

    private var currentIndex: Int = 0

    /// Shows the current step of the flow, it means that the next request will be received this as it's response
    public var currentStep: LetSeeMock? {
        guard currentIndex < mocks.count else {
            return nil
        }
        return mocks[currentIndex]
    }

    /// Moves the cursor to the next mock, when the request received the current mock, this function should be called.
    @discardableResult
    mutating func nextStep() -> LetSeeMock? {
        guard currentIndex < mocks.count else {
            return nil
        }

        let mock = mocks[currentIndex]
        self.currentIndex += 1
        return mock
    }
}

struct ScenarioFileInformation: Decodable {
    struct Step: Decodable {
        let folder: String
        let responseFileName: String
        
        init(folder: String, responseFileName: String) {
            self.responseFileName = responseFileName.lowercased()
            self.folder = folder.mockKeyNormalised
        }

        enum CodingKeys: CodingKey {
            case folder
            case responseFileName
        }

        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<ScenarioFileInformation.Step.CodingKeys> = try decoder.container(keyedBy: ScenarioFileInformation.Step.CodingKeys.self)
            let folder = try container.decode(String.self, forKey: ScenarioFileInformation.Step.CodingKeys.folder)
            let responseFileName = try container.decode(String.self, forKey: ScenarioFileInformation.Step.CodingKeys.responseFileName)
            self.init(folder: folder, responseFileName: responseFileName)
        }
    }

    var steps: [Step]
    init(steps: [Step]) {
        self.steps = steps
    }
}
