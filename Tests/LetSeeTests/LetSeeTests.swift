import XCTest
@testable import LetSee

final class LetSeeTests: XCTestCase {
    private var sut: LetSee?
    private let defaultMocksDirectoryName = "Mocks"
    private var defaultMocksDirectoryPath: String = ""
    override func setUp() {
        sut = LetSee(fileManager: MockFileManager())
        defaultMocksDirectoryPath = Bundle.module.path(forResource: defaultMocksDirectoryName, ofType: nil)!
    }

    override func tearDown() {
        sut = nil
        defaultMocksDirectoryPath = ""
    }

    func testLetSeeCorrectlyPrependsTheStringLetSeeToTheInputMessage(){
        let given = "some message"
        let result = print(given)
        let expected = "@LETSEE > \(given)"
        XCTAssertEqual(expected, result)
    }

    func testLetSeeCorrectlyInitializesWithTheDefaultConfiguration(){
        let given = LetSee.Configuration(isMockEnabled: true, shouldCutBaseURLFromURLsTitle: false, baseURL: "some url")
        sut = LetSee(configuration: given)

        XCTAssertEqual(sut!.configuration, given)
    }

    func testLetSeeCorrectlyUpdatesItsConfigurationUsingTheConfig(){
        let given = LetSee.Configuration(isMockEnabled: true, shouldCutBaseURLFromURLsTitle: false, baseURL: "some url")
        sut?.config(given)

        XCTAssertEqual(sut!.configuration, given)
    }

    func testLetSeeCorrectlyAddsMocksFromAGivenDirectoryPath_numberOFCategorizedMocksShouldBeEqualToNumberOfSubDirectoryInsideTheGivenMockDirectory(){
        let givenMockDirectory = defaultMocksDirectoryPath
        sut?.addMocks(from: givenMockDirectory)
        let numberOfCategorizedMocks = Bundle.module.paths(forResourcesOfType: nil, inDirectory: defaultMocksDirectoryName).count
        XCTAssertEqual(sut!.mocks.count, numberOfCategorizedMocks)
    }

    func testLetSeeCorrectlyAddsMocksFromAGivenDirectoryPath_numberOFMocksInCategorizedMockMocksArrayObjectShouldBeEqualToNumberOfAllJsonFilesInSideTheGivenDirectorySubDirectories(){
        let givenMockDirectory = defaultMocksDirectoryPath
        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: givenMockDirectory, ofType: "json")
        sut?.addMocks(from: givenMockDirectory)
        let numberOfJsonFiles = allJsonFilesInGivenMockDirectory.count
        XCTAssertEqual(sut!.mocks.map({$0.value.count}).reduce(0, +), numberOfJsonFiles)
    }

    func testLetSeeCorrectlyAddsMocksFromAGivenDirectoryPath_correctlyMakeSuccessOrFailureMockBasedOnTheFilename(){
        let givenMockDirectory = defaultMocksDirectoryPath
        let allJsonFilesInGivenMockDirectory = MockFileManager().recursivelyFindAllFiles(for: givenMockDirectory, ofType: "json")
        let expectedMocks = allJsonFilesInGivenMockDirectory
            .map({
                let json: String

                if let data = sut!.fileManager.contents(atPath: $0.absoluteString), let dataString = String(data: data, encoding: .utf8) {
                    json = dataString
                } else {
                    json = ""
                }
                return sut!.fileToMockMapper.map(fileName: $0.lastPathComponent, jsonData: json)
            })

        sut?.addMocks(from: givenMockDirectory)
        let result = sut!.mocks
            .flatMap(\.value)
        XCTAssertEqual(expectedMocks, result)
    }

    func testLetSeeCorrectlyAddsScenariosFromAGivenDirectoryPath(){

    }
    func testLetSeeCorrectlyCollectsFileUrlsFromAGivenDirectoryPath(){

    }
    func testLetSeeCorrectlyMakesAnHttpRequestIdentifiableByAddingAUniqueIdToItsHeaderFieldsUsingTheMakeidentifiableMethod(){

    }
    func testLetSeeCorrectlyInterceptsAndHandlesIncomingHttpRequests(){

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
