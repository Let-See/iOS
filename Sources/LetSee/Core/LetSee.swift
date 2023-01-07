import Foundation

final public class LetSee {
    private(set) public var configuration: Configuration = .default
    /// All available mocks that LetSee have found on the given mock directory
    private(set) public var mocks: Dictionary<String, Set<LetSeeMock>> = [:]
    /// All available scenarios that LetSee have found on the given scenario directory
    private(set) public var scenarios: [Scenario] = []
    public var onMockStateChanged: ((Bool) -> Void)?
    init() {}

    /// Sets the given `Configuration` for LetSee.
    ///
    /// - Parameters:
    ///   - config: the `Configuration` to be used by LetSee.
    public func config(_ config: Configuration) {
            self.configuration = config
        }

    /// Adds mock files from the given path to LetSee.
    ///
    /// - Parameters:
    ///   - path: the path of the directory that contains the mock files.
    public func addMocks(from path: String) {
            mocks = self.collectFiles(from: path)?
                .makeMock(parentDirectory: path) ?? [:]
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
    public func addScenarios(from path: String) {
        guard let scenarios = try? FileManager.default.contentsOfDirectory(atPath: path) else {
            return
        }
        self.scenarios = scenarios
            .filter({$0.hasSuffix(".plist")})
            .reduce(into: []) { partialResult, filePath in
                guard let scenario = NSDictionary(contentsOfFile:"\(path)/\(filePath)"), let steps = scenario["steps"] as? [Dictionary<String, String>] else {
                    return
                }
                let mocks = steps.compactMap { dic -> LetSeeMock? in
                    guard let key = dic["folder"],
                          let responseFile = dic["responseFileName"],
                          let availableMocks = self.mocks[key],
                          let mock = availableMocks.first(where: {$0.name.caseInsensitiveCompare(responseFile.removeSuccessOrErrorFormFileName()) == .orderedSame})  else {
                        print("Can not find the mock data with this informations: \n \(dic)" )
                        return nil
                    }
                    return mock
                }
                partialResult.append(.init(name: filePath, mocks: mocks))
        }
    }
    /**
     Collects all the files with the given file type from the given directory path, and returns a dictionary where each key is the name of a subdirectory and the value is an array of URLs for the files in that subdirectory.

     - Parameters:
        - path: The directory path to search for files.
        - fileType: The file extension of the files to collect. Defaults to "json".

     - Returns: A dictionary where each key is the name of a subdirectory and the value is an array of URLs for the files in that subdirectory, or `nil` if there was an error reading the directory.
     */
    private func collectFiles(from path: String, fileType: String = "json") -> Dictionary<String, [URL]>? {
       return try? FileManager.default.contentsOfDirectory(atPath: path)
            .reduce(into: [:], { partialResult, sub in
                let directoryPath = "\(path)/\(sub)"

                func getAllChild(on path: String) -> [URL] {
                    let url = URL(fileURLWithPath: directoryPath)
                    var files = [URL]()
                    if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
                        for case let fileURL as URL in enumerator {
                            do {
                                let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                                if fileAttributes.isRegularFile! {
                                    files.append(fileURL)
                                }
                            } catch { print(error, fileURL) }
                        }
                    }
                    return files.lazy.filter({$0.pathExtension == fileType})
                }


                let paths = getAllChild(on: directoryPath)
                guard paths.count > 0 else {return}
                partialResult.updateValue(paths, forKey: directoryPath)
            })
    }

    /// we add an id to headers of the request. this id helps LetSee to find the pending request easily
    public func makeIdentifiable(request: URLRequest) -> URLRequest {
        request.addLetSeeID()
    }
}

private extension Dictionary where Key == String, Value == [URL] {
    /**
      This function converts a dictionary of file paths to a dictionary of LetSeeMock objects.

      - Parameters:
          - parentDirectory: the path of the parent directory of the files.

      - Returns: a dictionary of LetSeeMock objects, where the keys are the names of the directories that the files are in, and the values are sets of LetSeeMock objects.
    */
    func makeMock(parentDirectory: String) -> Dictionary<String, Set<LetSeeMock>> {
        let directories = self
        return directories.reduce(into: [:], { partialResult, item in

            let mocks = item.value.compactMap { path -> LetSeeMock? in
                let fileURL = path
                guard let jsonData = try? String(contentsOf: fileURL)
                else {return nil}
                let fileName = fileURL.absoluteString
                    .replacingOccurrences(of: "file://\(item.key)/", with: "")
                    .lowercased()
                    .replacingOccurrences(of: ".json", with: "")
                if fileName.starts(with: "error_") {
                    return LetSeeMock.failure(name: fileName.removeSuccessOrErrorFormFileName(), response: .badServerResponse, data: jsonData)
                } else {
                    return LetSeeMock.success(name: fileName.removeSuccessOrErrorFormFileName(), response: .init(stateCode: 200, header: [:]), data: jsonData)
                }
            }
            partialResult.updateValue(Set(mocks), forKey: item.key.replacingOccurrences(of: "\(parentDirectory)/", with: "").lowercased())
        })
    }
}

extension LetSee {
    static let headerKey: String = "LETSEE-LOGGER-ID"
}

private extension String {
    func removeSuccessOrErrorFormFileName() -> String {
        self.replacingOccurrences(of: "error_", with: "")
        .replacingOccurrences(of: "success_", with: "")
    }
}

public extension LetSee {
    /**
      Runs a data task with the given request and calls the completion handler with the received data, response, and error.

      - Parameters:
        - request: The request to run the data task with.
        - completion: The completion handler to call with the received data, response, and error.

      - Returns: The data task that was run.
     */
    func runDataTask(using defaultSession: URLSession = URLSession.shared, with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let request = request.addLetSeeID()

        let session: URLSession
        if let interceptor = self as? InterceptorContainer, LetSee.shared.configuration.isMockEnabled {
            let configuration = interceptor.addLetSeeProtocol(to: defaultSession.configuration)
            session = URLSession(configuration: configuration)
            var categoriezedMocks: CategorisedMocks?
            if let url = request.url?.lastPathComponent, let defaultMocks = self.mocks[url] {
                categoriezedMocks = CategorisedMocks(category: .specific, mocks: Array(defaultMocks))
            }

            interceptor.interceptor.intercept(request: request, availableMocks: categoriezedMocks)
        } else {
            session = defaultSession
        }
        return session.dataTask(with: request, completionHandler: {(data , response, error) in
            let letSeeError = error as? LetSeeError
            completionHandler(data,response,letSeeError?.error ?? error)
        })
    }
}

