//
//  LetSeeBootStrap.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation

let letSee = LetSee()
public extension LetSee {
    static var shared: LetSeeProtocol {
        letSee
    }
}

public extension LetSee {
    /// Sets the given `Configuration` for LetSee.
    ///
    /// - Parameters:
    ///   - config: the `Configuration` to be used by LetSee.
    func config(_ config: Configuration) {
        self.configuration = config
    }

    /// Adds mock files from the given path to LetSee.
    ///
    /// - Parameters:
    ///   - path: the path of the directory that contains the mock files.
    func addMocks(from path: String) {
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
    func addScenarios(from path: String) {
        self.scenarios = parseScenarioPLists(from: path)
    }
    /**
      Runs a data task with the given request and calls the completion handler with the received data, response, and error.

      - Parameters:
        - request: The request to run the data task with.
        - completion: The completion handler to call with the received data, response, and error.

      - Returns: The data task that was run.
     */
    func runDataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        self.runDataTask(using: URLSession.shared, with: request, completionHandler: completionHandler)
    }
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
            completionHandler(data, response, letSeeError?.error ?? error)
        })
    }
}
