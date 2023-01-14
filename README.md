

# LetSee!
The LetSee library provides an easy way to provide mock data to your iOS application. The main intention of having a library like this is to have a way to mock the response of requests on runtime in an easy way to be able to test all available scenarios without the need to rerun or change the code or put in the extra effort.

**The idea is simple, Instead of writing too much code to provide mock data,** 
1. I want to save the server response in a JSON file and if the mocking is enabled, I want to respond to the specific request with one of those JSON files on the run time.
2. I want to be able to define scenarios, I don't want to always mock manually, Instead, I like to define a set of steps called `Scenario`, So each time a new request arrives It will get the proper response based on the current scenario's step 
3. I want to be able to customize the JSON request, like sometimes it would be easy to quickly change a property value to see completely different behavior, so instead of creating a new JSON file, It would be great if I could change the response like by Copy and Pasting a JSON string.
4. I want to be able to disable or enable the mock on the run time.
5. I want to be able to override the path of each mock folder like assigning `/azure/us/api/v2/orders/` to the `/Mocks/orders` so I don't need to create multiple empty subdirectories to mock that request responses

## Features
- **Easy to use**, LetSee receives a folder of your JSON mock data and lets you select them on the runtime
- **Scenarios**, sometimes you know what the scenario is and you don't want to mock each request manually, you provide a folder of your Scenarios and LetSee lets you select a scenario on the fly
- **On the fly response**, you are testing your application and suddenly some wired edge case comes to your mind, in this situation you can provide a totally custom json as the response to the request
- **Live To Server**, sometimes you don't want to mock all the requests but only some, in this case, you always have the option to do the actual request to the server instead of providing the mock response for those requests that you don't want to mock
- **Copy and Past**, you can copy a JSON and past it as the response to the request
- **Live Scenario Tracking**, If a scenario is activated, you can see the active scenario and the next response that will be passed to the next request
- **Change the Scenario On The Fly**, you can change the active scenario anytime you like without rerunning the application.

## How To Use

**Add the LetSee to your project** (SPM)
<img width="1159" alt="Screenshot 2023-01-10 at 23 23 55" src="https://user-images.githubusercontent.com/13612410/211781581-48972059-76eb-4eb6-a2fa-350994c556ba.png">
If you are still using **CocoaPods**, don't worry SPM and CocoaPods can coexist and live alongside each other peacefully, just

1. Select your project file
2. Select Package Dependencies 
3. and add LetSee (https://github.com/Let-See/LetSeeiOS)

**Add Mocks Folder to your project**

LetSee looks for a folder with the `Last Path Component` of your request like
`https://google.com/api/v2/orders` in this case, you need to have a subfolder in your Mocks called **orders ** and put all the samples JSON files into it, whenever LetSee intercepts that request, it will look inside the Mock folder and provide all JSON files as mocks for that request

for now, if the name of the JSON files can start in one of these ways:
1. **success_**: it means that this request is a successful request
2. **error_**: as you can tell, it means the mock would be a failed request
so you can create as many files as you want in the folders and all of those files will be parsed and ready for you to select as a response to the request.

**Add Scenarios Folder to your project**(Optional)

having a Scenarios folder is options, but if you prove LetSee with a path to you scenarios folder, it parses them and shows you a list of all scenarios and you can mock your requests based on your preferred scenario. A Scenario is a `.plist` files and describes the steps of that scenario and the response JSON file name (which should exist on the Mock JSON files folder)

**Setup the LetSee**

```swift
import LetSee
// somewhere like Appdelegate cofig the LetSee
LetSee.shared.config(LetSee.Configuration.init(isMockEnabled: false, shouldCutBaseURLFromURLsTitle: true, baseURL: serverBaseURL))
LetSee.shared.addMocks(from: Bundle.main.bundlePath + "/Mocks")
LetSee.shared.addScenarios(from: Bundle.main.bundlePath + "/Scenarios")
```
and where ever you handle the server calls, you can do something like this
```swift
#if DEBUG
	if  LetSee.shared.configuration.isMockEnabled {
		LetSee.shared.runDataTask(using: URLSession.shared, with: request, completionHandler: {data,res,err in
			DispatchQueue.main.async {
				completionHandler(res, data, err)
			}
		}).resume()
	} else{
		// execute the request normally
		URLSession.shared.runData....
	}
#endif
```
in the above code, We checked if the mocking is activated, the we let the LetSee intercepts the request (so we can mock it's response) otherwise, we will run the request normally.
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
