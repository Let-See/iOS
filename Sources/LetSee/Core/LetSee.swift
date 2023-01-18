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
    public var jsonFileParser: FileNameParsing
    public let interceptor: LetSeeInterceptor
    let mockProcessor: any MockProcessing
    let fileManager: FileManager
    let requestToMockMapper: RequestToMockMapper
    var globalMockDirectoryConfigs: GlobalMockDirectoryConfig?
    let scenarioProcessor: any ScenarioProcessing
    public init(configuration: Configuration = .default,
         fileManager: FileManager = .default,
         jsonFileParser: (any FileNameParsing)? = nil,
         interceptor: LetSeeInterceptor? = nil,
         mockProcessor: (any MockProcessing)? = nil,
         scenarioProcessor: (any ScenarioProcessing)? = nil,
         requestToMockMapper: RequestToMockMapper? = nil
    ) {
        self.configuration = configuration
        self.fileManager = fileManager
        self.jsonFileParser = jsonFileParser ?? JSONFileNameParser()
        self.interceptor = interceptor ?? LetSeeInterceptor()
        self.mockProcessor = mockProcessor ?? DefaultMockProcessor(directoryProcessor: MockDirectoryProcessor(fileNameParser: self.jsonFileParser))
        self.scenarioProcessor = scenarioProcessor ??  DefaultScenarioProcessor(mockFileNameParse: self.jsonFileParser)
        self.requestToMockMapper = requestToMockMapper ?? DefaultRequestToMockMapper.transform

    }
}

extension LetSee {
    static let headerKey: String = "LETSEE-LOGGER-ID"
}
