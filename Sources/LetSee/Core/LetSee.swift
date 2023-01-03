import Foundation

/// Adds @LETSEE>  at the beging of the print statement
///
/// - Parameters:
///    - message: the print string
internal func print(_ message: String) {
    Swift.print("@LETSEE > ", message)
}


final public class LetSee {
    public let mockUrlPaths: Set<LetSeeMock>
    public init(mockDirectoryPaths: (path: String, bundle: Bundle)...) {
        let mocks = mockDirectoryPaths
            .compactMap({ dir -> (files: [String], bundle: Bundle)? in
                guard let path = dir.bundle.path(forResource: dir.path, ofType: nil), let files = try? FileManager.default.contentsOfDirectory(atPath: path) else {return nil}
                return (files, dir.bundle)
            })

        let listOfMocks = mocks.compactMap({ contents -> [LetSeeMock]? in
            contents.files.compactMap { path -> LetSeeMock? in
                guard let fileAddress = contents.bundle.path(forResource: path, ofType: "json"),
                      let fileURL = URL(string: fileAddress),
                      let jsonData = try? String(contentsOfFile: fileAddress)
                else {return nil}
                return LetSeeMock.success(name: fileURL.lastPathComponent, response: .init(stateCode: 200, header: [:]), data: jsonData)
            }
        })
        .flatMap({$0})
        mockUrlPaths = Set(listOfMocks)
    }

    public init(mockFilePaths: [String]) {
        let mocks = mockFilePaths.compactMap({ file -> LetSeeMock? in
            guard let fileURL = URL(string: file),
                      let jsonData = try? String(contentsOfFile: file)
                else {return nil}
                return LetSeeMock.success(name: fileURL.lastPathComponent, response: .init(stateCode: 200, header: [:]), data: jsonData)
        })
        mockUrlPaths = Set(mocks)
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
        if let interceptor = self as? InterceptorContainer, self.interceptor.isMockingEnabled {
            let configuration = interceptor.addLetSeeProtocol(to: defaultSession.configuration)
            session = URLSession(configuration: configuration)
            interceptor.interceptor.intercept(request: request, availableMocks: availableMocks.union(self.mockUrlPaths))
        } else {
            session = defaultSession
        }

        return session.dataTask(with: request, completionHandler: {(data , response, error) in
            let letSeeError = error as? LetSeeError
            completionHandler(data,response,letSeeError?.error ?? error)
        })
    }
}

