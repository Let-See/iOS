
https://user-images.githubusercontent.com/13612410/212567902-b967615b-8f14-4c4c-b128-8e1529eade2c.mp4

# LetSee!
LetSee provides an easy way to provide mock data to your iOS application. The main intention of having a library like this is to have a way to mock the response of requests on runtime in an easy way to be able to test all available scenarios without the need to rerun or change the code or put in the extra effort.

**The idea is simple, Instead of writing too much code to provide mock data,** 
1. I want to save the server response in a JSON file and if the mocking is enabled, I want to respond to the specific request with one of those JSON files on the run time.
2. I want to be able to define scenarios, I don't want to always mock manually, Instead, I like to define a set of steps called `Scenario`, So each time a new request arrives It will get the proper response based on the current scenario's step.
3. I want to be able to customize the JSON response. Sometimes it would be easier to quickly change a property's value to see completely different behavior, so instead of creating a new JSON file, It would be great if I could change the response like by copying and Pasting the JSON response.
4. I want to be able to disable or enable the mock on the run time, when the mocking is disabled the requests should normally hit the server.
5. I want to be able to override the path of each mock folder like assigning `/azure/us/api/v2/orders` to the `/Mocks/orders` so I don't need to create multiple empty subdirectories to mock that request responses.

## Features
- **Easy to use**, LetSee receives a folder of your JSON files and lets you select them on the runtime, It is smart enough to show You only the responses related to that API call only.
- **Scenarios**, Sometimes You know what the scenario is and You don't want to mock each request's response manually, You provide a folder of your Scenarios, and LetSee lets You activate a scenario on run time, and will respond to all the requests respectively to the steps which have been defined in that scenario.
- **On the fly response**, You are testing your application and suddenly some wired edge case comes to your mind, in this situation You can provide a totally custom json as the response to the request by editing the response.
- **Live To Server**, Sometimes You don't want to mock all the requests but only some, in this case, You always have the option to send the request to the server instead of providing the mock response for those requests to get the live data.
- **Copy and Past**, You can copy a JSON and paste it as the response to the request from your clipboard.
- **Live Scenario Tracking**, If a scenario is activated, You can see the active scenario and the next response that will be given to the next request.
- **Change the Scenario On The Fly**, You can change the active scenario anytime you like without rerunning the application.

### Future (like the idea? here are some features that need your contribution to be alive)
- [ ] We can hide the LetSee button when mocking is not active and the user can use a gesture like shaking the phone to make it visible or invisible
- [ ] Ability to toggle between `Staging`, and `Dev` or other environments
- [ ] Recording scenarios on runtime
- [ ] Animation for showing the active scenario steps of a scenario would be cool
- [ ] Increasing the test coverage
- [ ] We can move to Kotlin Multi-Platform Mobile since this library could be useful on the other platform

# How To Use

## 1. Add the LetSee to your project (SPM)

<img width="1085" alt="image" src="https://user-images.githubusercontent.com/13612410/212571687-ef8ffda0-0038-416f-88db-1bc4878f20ef.png">
If you are still using **CocoaPods**, don't worry SPM and CocoaPods can coexist and live alongside each other peacefully, just

1. Select your project file
2. Select Package Dependencies 
3. and add LetSee (https://github.com/Let-See/LetSeeiOS) and the main branch

## 2. Add Mocks (and Scenarios if you'd like) Folder to your project
so basically, to map mocks folders to these URLs:
- https://someBaseURL/**products**
- https://someBaseURL/**categories**
- https://someBaseURL/**categories/filters**

you need to organize your mock folders like this:
- **Other folders**
- **Mocks**
  - **.ls.global.json** 
  - **products**
	  - success_productList.json
	  - success_emptyList.json
	  - success_listWithoutBanner.json
  - **categories**
	 - success_categoryList.json
	 - success_categoryEmptyList.json
	 - success_categotyListPagination.json
	 - error_categoryNotFound.json
	  - **filters**
		  - success_filterList.json  
		  - error_filterList.json 

and when an API request URL ends with one of those paths, LetSee makes all JSON files in that folder available on the run time for you to choose from. for example, when this request got intercepted `https://someBaseURL/products`, you can choose one of these mock responses `success_productList.json`, `success_emptyList.json`, `sucess_listWithoutBanner.json` to answer it. 

### What is .ls.global.json?
You may notice that there is a **.ls.global.json** file in the root mock folder, It can be utilized to map your mocks structure to more complicated addresses. Let's assume that your requests have various paths, like these
- https://someBaseURL/**v1/staging/products**
- https://someBaseURL/**v2/something/something/categories**
- https://someBaseURL/**v2/something/something/categories/filters**
so instead of creating many empty subdirectories, You can use **.ls.global.json** to override the mapping 
**.ls.global.json**
```json
{
	"maps": [
		{
			"folder": "/products",
			"to": "/v1/staging" 
		},
		{
			"folder": "/categories",
			"to": "/v2/something/something"
		}
	]
}
```

### File types
For now, the name of the JSON files can begin with these:
1. **success_**: it means that this request is a successful request **(default value will be success, it means that the JSON file would be considered as an error mock provide the name begins with **error_**)**
2. **error_**:  as you can tell, it means the mock would be a failed request

So you can create as many files as you want in the folders, and all those files will be parsed and ready for you to be chosen by You as a response to the request.

**Add Scenarios Folder to your project**(Optional)
Scenario lets you automate the responding, each Scenario has a `steps` property that describes the steps that this scenario takes. for example, We can define a scenario for `Transfer Money `, users there would be many API calls involved in that scenario:

- List of user accounts
- List of contacts
- Payment
- List of transactions

by default, all the requests will be intercepted by LetSee (if the mock is enabled) and they will be waiting to get their response, and We need to select a mock response for them manually, but with Scenarios, LetSee will do it for us.
LetSee passes through the scenario steps and once a new request arrives, LetSee responds to it with the current step of the scenario until all the scenarios steps get processed and then LetSee automatically disabled the scenario and the next requests will be intercepted normally and they will wait for the manual action. 

having a Scenarios folder is an option, but if you provide LetSee with a path to your scenarios folder, it parses them and shows you a list of all available scenarios and you can mock your requests based on your preferred scenario. A Scenario is a `.plist` file and describes the steps of that scenario and the response JSON file name (which should exist in the Mock JSON files folder)

<img width="403" alt="image" src="https://user-images.githubusercontent.com/13612410/212570773-9d998113-00bb-4860-81a5-da5a4e75932e.png">

### Scenario's Step Properties
each step should have two properties that indicate the name of the folder containing the mock file and the file name

**folder**: name of the folder that contains the mock file

**responseFileName**: the full name of the JSON mock file

## 3. Setup the LetSee

```swift
import LetSee
// Somewhere like Appdelegate cofig the LetSee
// Configs LetSee
LetSee.shared.config(LetSee.Configuration.init(baseURL: URL(string: "https://api.thecatapi.com/")!,
					       isMockEnabled: false,
					       shouldCutBaseURLFromURLsTitle: true))
LetSee.shared.addMocks(from: Bundle.main.bundlePath + "/Mocks/Mocks")
LetSee.shared.addScenarios(from: Bundle.main.bundlePath + "/Mocks/Scenarios")

// Configs LetSee window, it makes the LetSeeButton be appear on top
let letSeeWindow = LetSeeWindow(frame: window.frame)
letSeeWindow.windowScene = window.windowScene

```
and where ever you are handling the server calls, you can do something like this
```swift
let task: URLSessionDataTask
#if RELEASE
	// Calls the production server
	task = URLSession.shared.runDataTask(with: request, completionHandler: completionHandler)
#else
if LetSee.shared.configuration.isMockEnabled {
	// LetSee intercepts the request 
	task = LetSee.shared.runDataTask(using: .shared, with: request, completionHandler: completionHandler)
} else {
	// Calls the real server 
	task = URLSession.shared.dataTask(with: request, completionHandler: completionHandler)
}
#endif

task.resume()
```
in the above code, We checked if the mocking is activated, then we let the LetSee intercepts the request (so we can mock its response) otherwise, we will run the request normally.
now run your application and enjoy it.

flow chart:

```mermaid
graph LR
A[New request] --> B{isMockingEnabled}
B --Yes--> C(LetSee)
B --No--> D((Normal API call))
C --> F{IsScenarioEnabled}
F --Yes--> G(NextStep)
F --No--> E((AvailableMocks))
G --Automatic--> H
E --Manually Select Reponse--> H
D --Server Responses--> H(Response to the request)
