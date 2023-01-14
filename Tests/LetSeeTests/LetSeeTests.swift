import XCTest
@testable import LetSee
extension MockFileManager {
    static let defaultMocksDirectoryName = "Mocks"
    static let defaultMockScenariosDirectoryName = "MockScenarios"
    static var defaultMocksDirectoryPath: String {
        Bundle.module.path(forResource: defaultMocksDirectoryName, ofType: nil)!
    }
    static var defaultMockScenariosDirectoryPath: String {
        Bundle.module.path(forResource: defaultMockScenariosDirectoryName, ofType: nil)!
    }
}

final class LetSeeTests: XCTestCase {
    private var sut: LetSee!
    private var defaultBaseURL = URL(string: "https://google.com/")!
    override func setUp() {
        sut = LetSee(fileManager: MockFileManager())
        LetSee.injectLetSee(sut)
    }

    override func tearDown() {
        sut = nil
    }

    func testLetSeeCorrectlyPrependsTheStringLetSeeToTheInputMessage(){
        let given = "some message"
        let result = print(given)
        let expected = "@LETSEE > \(given)"
        XCTAssertEqual(expected, result)
    }

    func testLetSeeCorrectlyInitializesWithTheDefaultConfiguration(){
        let given = LetSee.Configuration(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: false)
        sut = LetSee(configuration: given)

        XCTAssertEqual(sut!.configuration, given)
    }

    func testLetSeeCorrectlyUpdatesItsConfigurationUsingTheConfig(){
        let given = LetSee.Configuration(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: false)
        sut?.config(given)

        XCTAssertEqual(sut!.configuration, given)
    }

    func testLetSeeCorrectlyAddsMocksFromAGivenDirectoryPath_numberOFMocksInCategorizedMockMocksArrayObjectShouldBeEqualToNumberOfAllJsonFilesInSideTheGivenDirectorySubDirectories(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: givenMockDirectory, ofType: "json")
        sut?.addMocks(from: givenMockDirectory)
        let numberOfJsonFiles = allJsonFilesInGivenMockDirectory.count
        XCTAssertEqual(sut!.mocks.map({$0.value.count}).reduce(0, +), numberOfJsonFiles)
    }

    func testLetSeeCorrectlyAddsMocksFromAGivenDirectoryPath_correctlyMakeSuccessOrFailureMockBasedOnTheFilename(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: givenMockDirectory, ofType: "json")
        let expectedMocks = allJsonFilesInGivenMockDirectory
            .map({
                let json: String = (try? String(contentsOf: $0)) ?? ""
                return sut!.fileToMockMapper.map(fileName: $0.lastPathComponent, jsonData: json)
            })
            .sorted()
        sut?.addMocks(from: givenMockDirectory)
        let result = sut!.mocks
            .flatMap(\.value)
            .sorted()
        XCTAssertEqual(expectedMocks.map(\.type), result.map(\.type))
    }

    func testLetSeeCorrectlyAddsScenariosFromAGivenDirectoryPath(){
        let configs = GlobalMockDirectoryConfig.isExists(in: URL(fileURLWithPath: MockFileManager.defaultMocksDirectoryPath))!
        let mockProcessor = DefaultMockProcessor()
        let mocks = try! mockProcessor.buildMocks(MockFileManager.defaultMocksDirectoryPath)
        let scenarioProcessor = DefaultScenarioProcessor()
        let expectedScenarios = try! scenarioProcessor.buildScenarios(for: MockFileManager.defaultMockScenariosDirectoryPath, requestToMockMapper: {path in
            DefaultRequestToMockMapper.transform(request: URL(string: "https://letsee.com/" + path)!, using: mocks)
        }, globalConfigs: configs)


        let givenMockScenariosDirectory = MockFileManager.defaultMockScenariosDirectoryPath
        let allPlistFilesInGivenMockScenario = MockFileManager()
            .recursivelyFindAllFiles(for: givenMockScenariosDirectory, ofType: "plist")
        sut?.addMocks(from: MockFileManager.defaultMocksDirectoryPath)
        sut?.addScenarios(from: givenMockScenariosDirectory)
        let result = sut!.scenarios

        XCTAssertEqual(expectedScenarios, result)
    }

    func testLetSeeCorrectlyInterceptsIncomingHttpRequests(){
        let request = URLRequest(url: URL(string: "\(defaultBaseURL)/arrangements")!)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.runDataTask(with: request) { _, _, _ in

        }
        XCTAssertTrue(sut!.interceptor._requestQueue.count > 0)
    }

    func testLetSeeCorrectlyInterceptsIncomingHttpRequestsShouldAddGeneralMocks(){
        let request = URLRequest(url: URL(string: "https://google.com/arrangements")!)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.runDataTask(with: request) { _, _, _ in

        }
        XCTAssertTrue(sut!.interceptor._requestQueue.count > 0)
        XCTAssertFalse(sut!.interceptor._requestQueue[0].mocks.filter({$0.category == .general}).isEmpty)
    }

    func testLetSeeCorrectlyInterceptsAndAddsMocksToTheRequestForParentDirectory(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let url = URL(string: "\(defaultBaseURL)")!.appendingPathComponent("/api/arrangement-manager/client-api/v2/productsummary/context/arrangements")
        let request = URLRequest(url: url)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.addMocks(from: givenMockDirectory)
        sut!.runDataTask(with: request) { _, _, _ in}
        XCTAssertFalse(sut!.interceptor._requestQueue[0].mocks.filter({$0.category == .specific}).isEmpty)
    }

    func testLetSeeCorrectlyInterceptsAndAddsMocksToTheRequestForChildDirectory(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let url = URL(string: "\(defaultBaseURL)")!.appendingPathComponent("/api/arrangement-manager/client-api/v2/productsummary/context/arrangements/innerpath")
        let request = URLRequest(url: url)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.addMocks(from: givenMockDirectory)
        sut!.runDataTask(with: request) { _, _, _ in}
        XCTAssertEqual(sut!.interceptor._requestQueue[0].mocks
            .first(where: {$0.category == .specific})?
            .mocks.count, 1)
    }

    func testLetSeeCorrectlyInterceptsAndAddsMocksToTheRequestForChildDirectoryLowestPath(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let url = URL(string: "\(defaultBaseURL)")!.appendingPathComponent("/api/arrangement-manager/client-api/v2/productsummary/context/arrangements/innerpath/thelowestpath")
        let request = URLRequest(url: url)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.addMocks(from: givenMockDirectory)
        sut!.runDataTask(with: request) { _, _, _ in}
        XCTAssertEqual(sut!.interceptor._requestQueue[0].mocks
            .first(where: {$0.category == .specific})?
            .mocks.count, 1)
    }

    func testLetSeeCorrectlyInterceptsAndAddsMocksToTheRequestForMainDirectory(){
        let givenMockDirectory = MockFileManager.defaultMocksDirectoryPath
        let url = URL(string: "\(defaultBaseURL)")!.appendingPathComponent("/api/arrangement-manager/client-api/v2/productsummary/context/arrangements")
        let request = URLRequest(url: url)
        sut!.config(.init(baseURL: defaultBaseURL, isMockEnabled: true, shouldCutBaseURLFromURLsTitle: true))
        sut!.addMocks(from: givenMockDirectory)
        sut!.runDataTask(with: request) { _, _, _ in}
        XCTAssertEqual(sut!.interceptor._requestQueue[0].mocks
            .first(where: {$0.category == .specific})?
            .mocks.count, 2)
    }

    func testLetSeeCorrectlyHandlesLiveRequestsByForwardingThemToTheServer(){

    }
    func testLetSeeCorrectlyHandlesMockRequestsByReturningTheAppropriateMockResponse(){

    }
}

/* Interceptor

 Test that CategorizedMocks correctly conforms to the Hashable protocol by implementing hash(into hasher: inout Hasher) and ==(lhs: Self, rhs: Self) -> Bool.
 Test that LetSeeUrlRequest has the correct properties and initializes them correctly in its initializer.
 Test that LetSee.sessionConfiguration correctly creates and returns a URLSessionConfiguration object with the correct timeout intervals and protocol classes.
 Test that LetSee.addLetSeeProtocol(to:) correctly adds the LetSeeURLProtocol class to the given URLSessionConfiguration object's protocol classes.
 Test that LetSee correctly conforms to the InterceptorContainer protocol by returning the correct LetSeeInterceptor object in its interceptor property.
 Test that Scenario correctly conforms to the Equatable protocol by implementing ==(lhs: Self, rhs: Self) -> Bool.
 Test that Scenario correctly initializes its properties and has the correct current step and next step behavior in its currentStep and nextStep() methods.
 Test that LetSeeInterceptor correctly initializes its _requestQueue property as an empty array and has the correct behavior for its add(request:) and remove(request:) methods.
 Test that LetSeeInterceptor correctly activates and deactivates a scenario using its activate(scenario:) and deactivateScenario() methods.
 Test that LetSeeInterceptor correctly processes requests using its process(request:response:) method.
 Test that LetSeeInterceptor correctly cancels requests using its cancel(request:) method.
 Test that LetSeeInterceptor correctly responds to requests using its respond(request:response:) method.
 Test that LetSeeInterceptor correctly suspends requests using its suspend(request:) method.
 Test that LetSeeInterceptor correctly resumes suspended requests using its resume(request:) method.
 Test that LetSeeInterceptor correctly handles mock failures using its fail(request:error:) method.
 Test that LetSeeInterceptor correctly records request history using its record(request:response:) method.
 Test that LetSeeInterceptor correctly returns request history using its history(for:) method.
 Test that LetSeeInterceptor correctly returns a list of all recorded requests using its allRequests() method.
 Test that LetSeeInterceptor correctly records a scenario using its record(scenario:) method.
 Test that LetSeeInterceptor correctly returns a list of all recorded scenarios using its allScenarios() method.
 */

/* LetSeeMock
 Test that Category correctly initializes and returns the correct name for each category type.
 Test that LetSeeMock correctly conforms to the Hashable and Comparable protocols by implementing hash(into:) and <(lhs:rhs:) respectively.
 Test that LetSeeMock correctly initializes and returns the correct name, data, and string values for each mock type.
 Test that LetSeeMock correctly formats JSON data into a pretty-printed string using its formatted property.
 Test that LetSeeMock correctly maps JSON data onto an existing mock using its mapJson(_:) method.
 Test that LetSeeMock correctly creates a URLResponse object from a mock using its response property.
 Test that LetSeeMock correctly creates a URLRequest object from a mock using its request(url:) method.
 Test that LetSeeMock correctly creates a URLRequest object with a custom header field from a mock using its request(url:headers:) method.
 Test that LetSeeMock correctly creates a URLRequest object with a custom HTTP method from a mock using its request(url:method:) method.
 Test that LetSeeMock correctly creates a URLRequest object with a custom HTTP method and header fields from a mock using its request(url:method:headers:) method.
 */
