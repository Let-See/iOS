import Foundation

/// Adds @LETSEE>  at the beging of the print statement
///
/// - Parameters:
///    - message: the print string
internal func print(_ message: String) {
    Swift.print("@LETSEE > ", message)
}

public typealias LiveToServer = (_ request: URLRequest, _ completion: ((Data?, URLResponse?, Error?) -> Void)?) -> Void

let letSee = LetSee()
public extension LetSee {
    static var shared: LetSee {
        letSee
    }
}

final public class LetSee {
    private(set) public var configuration: Configuration = .default
    private(set) public var defaultMocks: Dictionary<String, Set<LetSeeMock>> = [:]
    public var onMockStateChanged: ((Bool) -> Void)?
    init() {}

    public func config(_ config: Configuration) {
        self.configuration = config
    }

    public func addMocks(from directory: String, on bundle: Bundle) {
        guard let mocks: Dictionary<String, [String]> = try? FileManager.default.contentsOfDirectory(atPath: bundle.bundlePath + "/\(directory)")
            .reduce(into: [:], { partialResult, sub in
                let directoryPath = "\(directory)/\(sub)"
                let paths = bundle.paths(forResourcesOfType: "json", inDirectory: directoryPath)
                guard paths.count > 0 else {return}
                partialResult.updateValue(paths, forKey: directoryPath)
            }) else {
            defaultMocks = [:]
            return
        }

        defaultMocks = mocks.reduce(into: [:], { partialResult, item in
            let mocks = item.value.compactMap { path -> LetSeeMock? in
                guard let fileURL = URL(string: path),
                      let jsonData = try? String(contentsOfFile: path)
                else {return nil}
                let fileName = fileURL.lastPathComponent.replacingOccurrences(of: ".json", with: "")
                if fileName.starts(with: "error_") {
                    return LetSeeMock.failure(name: fileName.replacingOccurrences(of: "error_", with: ""), response: .badServerResponse, data: jsonData)
                } else {
                    return LetSeeMock.success(name: fileName.replacingOccurrences(of: "success_", with: ""), response: .init(stateCode: 200, header: [:]), data: jsonData)
                }
            }
            partialResult.updateValue(Set(mocks), forKey: item.key.replacingOccurrences(of: "\(directory)/", with: "").lowercased())
        })
    }

    /// we add an id to headers of the request. this id helps LetSee to find the pending request easly
    public func makeIdentifiable(request: URLRequest) -> URLRequest {
        request.addLetSeeID()
    }
}

extension LetSee {
    static let headerKey: String = "LETSEE-LOGGER-ID"
}

public extension LetSee {
    func runDataTask(using defaultSession: URLSession = URLSession.shared, with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void, availableMocks: Set<LetSeeMock> = []) -> URLSessionDataTask {
        let request = request.addLetSeeID()

        let session: URLSession
        if let interceptor = self as? InterceptorContainer, LetSee.shared.configuration.isMockEnabled {
            let configuration = interceptor.addLetSeeProtocol(to: defaultSession.configuration)
            session = URLSession(configuration: configuration)
            var mocks = availableMocks
            if let url = request.url?.lastPathComponent, let defaultMocks = defaultMocks[url] {
                mocks = mocks.union(defaultMocks)
            }
            interceptor.interceptor.intercept(request: request, availableMocks: mocks)
        } else {
            session = defaultSession
        }
        return session.dataTask(with: request, completionHandler: {(data , response, error) in
            let letSeeError = error as? LetSeeError
            completionHandler(data,response,letSeeError?.error ?? error)
        })
    }
}

