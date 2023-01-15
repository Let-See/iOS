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
	@State var letSeeWindow: UIWindow?
	var window: UIWindow? {
		   guard let scene = UIApplication.shared.connectedScenes.first,
				 let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
				 let window = windowSceneDelegate.window else {
			   return nil
		   }
		let letSeeWindow = LetSeeWindow(frame: window!.frame)
		letSeeWindow.windowScene = window!.windowScene
		self.letSeeWindow = letSeeWindow
		LetSee.shared.config(LetSee.Configuration.init(baseURL: URL(string: "https://api.thecatapi.com/")!, isMockEnabled: false, shouldCutBaseURLFromURLsTitle: true))
		LetSee.shared.addMocks(from: Bundle.main.bundlePath + "/Mocks")
		LetSee.shared.addScenarios(from: Bundle.main.bundlePath + "/Scenarios")
		return window
	}
    var body: some Scene {
        WindowGroup {
            ContentView()
				.onAppear {
					guard let window = window else {
						return
					}
				}
        }

    }
}

