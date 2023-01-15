//
//  CatAPIProjectApp.swift
//  CatAPIProject
//
//  Created by Karin Prater on 20.08.21.
//

import SwiftUI
import LetSee
import LetSeeInAppView
@main
struct CatAPIProjectApp: App {
	@State var letSeeWindow: UIWindow? {
		didSet {
			LetSee.shared.config(LetSee.Configuration.init(baseURL: URL(string: "https://api.thecatapi.com/")!,
														   isMockEnabled: false,
														   shouldCutBaseURLFromURLsTitle: true))
			LetSee.shared.addMocks(from: Bundle.main.bundlePath + "/Mocks/Mocks")
			LetSee.shared.addScenarios(from: Bundle.main.bundlePath + "/Mocks/Scenarios")
			LetSee.shared.interceptor.liveToServer = { request, completion in
				URLSession.shared.dataTask(with: request, completionHandler: { data, res, err in
					completion?(res, data, err)
				})
				.resume()
			}
		}
	}
	var window: UIWindow? {
		guard let scene = UIApplication.shared.connectedScenes.first,
			  let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
			  let window = windowSceneDelegate.window else {
			return nil
		}
		return window
	}
	var body: some Scene {
		WindowGroup {
			ContentView()
				.onAppear {
					guard let window = window else {
						return
					}
					let letSeeWindow = LetSeeWindow(frame: window.frame)
					letSeeWindow.windowScene = window.windowScene
					self.letSeeWindow = letSeeWindow
				}
		}

	}
}

