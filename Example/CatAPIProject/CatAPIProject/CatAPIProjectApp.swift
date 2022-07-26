//
//  CatAPIProjectApp.swift
//  CatAPIProject
//
//  Created by Karin Prater on 20.08.21.
//

import SwiftUI
import Letsee_InAppView
@main
struct CatAPIProjectApp: App {
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

					letSee.insertLetSeeButton(on: window)
				}
        }

    }
}
