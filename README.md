# Welcome and "LetSee"!
**LetSee creates a web application on your phone** and **logs** all the **API requests** for you, and **shows them** on **the web application** located on your device IP address like below, more over **LetSee has another cool feature, an InAppView** which lets you **choose** your **mock response (or completely custom response)** for each request in your application. 
<img src ="https://raw.githubusercontent.com/farshadjahanmanesh/Letsee/main/Examples+Images/LetSee_webapplication.png"/>
|<img src ="https://raw.githubusercontent.com/farshadjahanmanesh/Letsee/main/Examples+Images/LetSee_mocks.png" width="100%"/> | <img src ="https://raw.githubusercontent.com/farshadjahanmanesh/Letsee/main/Examples+Images/LetSee_custom%20response.png" width="100%"/>  |
|--|--|

### Current Features  🎉🎉
1.  list of requests
2.  request details (Response, Request body, and headers)
3.  JSON viewer (collapse, fold, and copy JSON body)
4.  copy button (copies full request details)
5.  searchable list
6.  mock provider
7.  custom JSON response

**Incoming Features on the Web Application**
1. test scenario
2. copy from clipboard
3. sections for mocks
5. hide the base url

4. 
1.  custom response and mock JSON, editable response just like InAppView
2.  JSON data from file (on InAppView too)
3.  light mode
4. responsive layout
5. alamofire proxy 
6. It is a good idea to have a **BaseURL Provider**, this way, we can achieve `Feature/URL` (DevOps team provides a new BaseUrl for each new feature, and QA team tests each feature simultaneously without requiring a new build)

## Table of Contents

* [What is wrong with Xcode's console ](#what-is-wrong-with-xcodes-console)
* [Add LetSee to your project ](#add-letSee-to-your-project)
* [Use LetSee (in 4 Steps)](#2.-Use-LetSee-(in-4-Steps))
* [Modularization](#modularization)
	* [Core](#core)
	* [In App View](#in-app-view)

## What is wrong with Xcode's console?

Many applications need to handle API calls and communicate with servers. The problem is by logging API calls (requests and responses) in **Xcode's console**, you see a very **crowded terminal, nasty and confusing** information, moreover for a piece of data, you have to look through all printed texts in the terminal alongside with **interface issues, library warnings, other logs** and more ... within a very ordinary, unorganized and pale color place. Are you tired of this?

![alt text](https://github.com/farshadjahanmanesh/Letsee/blob/main/Examples%2BImages/bad.jpg?raw=true)

## Then what is LetSee?
**LetSee**, lets you see what is going on between your application and the server in a **very neat, clean, and organized** space. Do you like this?

https://user-images.githubusercontent.com/13612410/181033778-b65fe682-0185-4bad-a6a5-7375845af5d8.mp4

LetSee consists of 2 modules to do its job which we will talk about them in the following section
> **Note:** We took _inspiration_ from [**WatchTower**](https://github.com/adibfara/WatchTower) written by [Adibfara](https://github.com/adibfara).

## Add LetSee to your project:
using this library is undoubtedly easy, currently, we support **CocoaPods** and **Swift Package Manager**

#### CocoaPods
just import LetSee simply like other pods
```ruby
// imports just core features (logging mechanisms and web application)
pod 'LetSee' 

// imports inAppView which is a SwiftUI Page(to manage mocks and custom responses) and `See` Button 
pod 'LetSee/InAppView' 
```

## 2. Use LetSee ( in 4 Steps )
it is completely up to you, if you have multiple Moya providers, you can keep LetSee as a global Variable otherwise just keep LetSee wherever you need it and be sure that its instance would be alive till you need the logger

 1. #### Import it and keep it strongly
	```swift
	#if DEBUG
		// GlobalScope, (or somewhere else as your call)
		import LetSee
		let  letSee = LetSee("https://YourBaseURL/")
	#endif
	```
2. #### run your request using LetSee, it runs it on your URLSession, logs it, and calls your completion function back with the response.
	```swift
	struct APIService: APIServiceProtocol {
	    func fetchBreeds(url: URL?, completion: @escaping(Result<[Breed], APIError>) -> Void) {
			let request = URLRequest(url: url)
			/// your callback function
			let completionHandler: ((Data?, URLResponse?, Error?) -> Void) = {(data , response, error) in
				/// do what ever you want to do with the response
			}
			let task: URLSessionDataTask
			// just some check to make sure that we are using LetSee only in development
			#if RELEASE
				task = URLSession.shared.runDataTask(with: request, completionHandler: completionHandler)
			#else
				task = letSee.runDataTask(with: request, completionHandler: completionHandler, availableMocks: Breed.mocks)
			#endif

			task.resume()
		}
	}
	```
3. #### Are you Using Moya? it's really easy integrating LetSee and Moya
	Then you need to pass the `LetSeeLogs` to `Moya` as a plugin like this.  **LetSeeLogs** is a MoyaPlugin that interrupts the requests and logs them into LetSee
	```swift
	#if DEBUG
	...
	provider = MoyaProvider<Apis>(plugins:[LetSeeLogs(webServer: letSee.webServer), LetSeeInAppLogs(interceptor: letSee.interceptor)])
	#endif
	```
4. #### Bon Appétit
	Yes, that's it. Done, congratulation. Now just look at your Xcode's console for this message
	```batch
	// the server address could be something else on your machine
	@LETSEE>  Server has started (192.168.1.100:8080/). 
	```


# Modularization
LetSee consists of 2 modules, each module brings a set of powerful tools to facilitate working with your networking system.

## Core
<img width="505" alt="image" src="https://user-images.githubusercontent.com/13612410/166746755-dd48bdcd-8f1d-4a6d-959d-401291dcdf89.png">

### LetSee Core Features
-   Tracks and observes all API calls made through Moya, Alamofire, and ...'s client
-   GET, POST, PUT, DELETE, PATCH methods
-   Query parameters, request and response body, and headers
-   Response success and failure status, size, date, and latency
-   Adjustable port for the server and the WebSocket server
-   API call history, even If no browsers were open
-   Search in the URLs of all requests
-   Fully responsive UI
## In App View
<img width="200" alt="image" src="https://user-images.githubusercontent.com/13612410/166746802-0df3b7a4-07f4-4fba-8f79-6bc51637b9e1.png">

### LetSee In App View Features
- Facilitates network request mocking 
- Provides a neat way for defining mock response
- Intercepts the URLRequests and lets you choose a corresponding response
- Provides 4 default responses for every request (Live, Cancel, Custom Success, Custom Error)
- Lets you edit the response JSON
- Helps you test all of the response scenarios (to check if all scenarios have been implemented)
- Has a beautiful SwiftUI view 
