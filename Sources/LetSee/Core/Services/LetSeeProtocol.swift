//
//  LetSeeProtocol.swift
//  
//
//  Created by Farshad Jahanmanesh on 07/01/2023.
//

import Foundation
/*
 The LetSeeProtocol protocol defines a set of methods and properties that allow the configuration and management of mock data and scenarios for a given session.

 The configuration property is a LetSee.Configuration struct that specifies the current configuration of the session. The mocks property is a dictionary of mock data organized by category. The scenarios property is an array of Scenario structs that represent combinations of mock data to use for a specific flow. The onMockStateChanged property is a closure that will be called when the mock data state changes.

 The config(_:) method allows you to update the session's configuration. The addMocks(from:) method adds mock data from the specified file path. The addScenarios(from:) method adds scenarios from the specified file path. The runDataTask(using:with:completionHandler:) method runs a data task using the specified session and request, and calls the completion handler with the data, response, and error when the task is completed.
 */
public protocol LetSeeProtocol: AnyObject {

    /// The `Configuration` to be used by LetSee.
    var configuration: LetSee.Configuration {get}

    /// All available mocks that LetSee have found on the given mock directory
    var mocks: Dictionary<String, Set<LetSeeMock>> {get}

    /// All available scenarios that LetSee have found on the given scenario directory
    var scenarios: [Scenario] {get}

    /// A closure that is called when the mock state of the LetSee object changes. It takes a single argument, a Bool value indicating whether mock is enabled or not. It can be set or retrieved using the set and get functions.
    var onMockStateChanged: ((Bool) -> Void)?  {set get}
    var fileToMockMapper: FileToLetSeeMockMapping {get}
    var interceptor: LetSeeInterceptor {get}

    /// Sets the given `Configuration` for LetSee.
    ///
    /// - Parameters:
    ///   - config: the `Configuration` to be used by LetSee.
    func config(_ config: LetSee.Configuration)

    /// Adds mock files from the given path to LetSee.
    ///
    /// - Parameters:
    ///   - path: the path of the directory that contains the mock files.
    func addMocks(from path: String)
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
    func addScenarios(from path: String)

    /**
      Runs a data task with the given request and calls the completion handler with the received data, response, and error.

      - Parameters:
        - request: The request to run the data task with.
        - completion: The completion handler to call with the received data, response, and error.

      - Returns: The data task that was run.
     */
    func runDataTask(using defaultSession: URLSession, with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}
