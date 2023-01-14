import Foundation
extension LetSee {
    static let configsFileName = ".pathconfigs.json"
}
/// The LetSee object that serves as the entry point to the library and provides access to the features.
final public class LetSee: LetSeeProtocol {
    internal(set) public var configuration: Configuration = .default
    /// All available mocks that LetSee have found on the given mock directory
    internal(set) public var mocks: Dictionary<String, Set<LetSeeMock>> = [:]
    /// All available scenarios that LetSee have found on the given scenario directory
    internal(set) public var scenarios: [Scenario] = []
    /// a closure that is called when the mock state of the LetSee object changes. It takes a single argument, a Bool value indicating whether mock is enabled or not. It can be set or retrieved using the set and get functions.
    public var onMockStateChanged: ((Bool) -> Void)?
    public let fileToMockMapper: FileToLetSeeMockMapping
    public let interceptor: LetSeeInterceptor
    let mockProcessor: any MockProcessing
    let fileManager: FileManager
    let requestToMockMapper: RequestToMockMapper
    init(configuration: Configuration = .default, fileManager: FileManager = .default,
         fileToMockMapper: FileToLetSeeMockMapping = DefaultFileToLetSeeMockMapping(),
         interceptor: LetSeeInterceptor = .init(),
         mockProcessor: any MockProcessing = DefaultMockProcessor(),
         requestToMockMapper: @escaping RequestToMockMapper = DefaultRequestToMockMapper.transform
    ) {
        self.configuration = configuration
        self.fileManager = fileManager
        self.fileToMockMapper = fileToMockMapper
        self.interceptor = interceptor
        self.mockProcessor = mockProcessor
        self.requestToMockMapper = requestToMockMapper
    }

    /**
     Adds the scenarios from the given directory path to the `scenarios` property of the `LetSee` instance.

     The `scenarios` property is a dictionary where each key is the name of the scenario file, and the value is an array of `LetSeeMock` objects that represent the mocks for each step of the scenario.

     The scenario files should be in the form of Property List (.plist) files, and should contain a top-level key called "steps" which is an array of dictionaries. Each dictionary should contain the following keys:
     - "folder": The name of the folder containing the mock data for this step.
     - "responseFileName": The name of the mock data file (with or without the "success" or "error" prefix).

     If the `LetSee` instance cannot find a mock data file with the given name and folder, it will print an error message and skip that step in the scenario.

     - Parameters:
     - path: The directory path where the scenario files are located.
     */
    func parseScenarioPLists(from path: String) ->  [Scenario] {
        guard let scenarios = try? fileManager.contentsOfDirectory(atPath: path) else {
            return []
        }
        return scenarios
            .filter({$0.hasSuffix(".plist")})
            .reduce(into: []) { partialResult, fileName in
                guard let scenario = NSDictionary(contentsOfFile:"\(path)/\(fileName)") else {
                    return
                }
                partialResult.append(.init(from: scenario, availableMocks: self.mocks, fileToMockMapper: self.fileToMockMapper, fileName: fileName))
            }
    }
}

extension LetSee {
    static let headerKey: String = "LETSEE-LOGGER-ID"
}
