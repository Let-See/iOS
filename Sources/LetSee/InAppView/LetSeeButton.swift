//
//  LetSeeButton.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 7/26/22.
//

import Foundation
import SafariServices
import SwiftUI
#if SWIFT_PACKAGE
import Letsee_Core
#endif

private var strongReferenceLetSeeButton: LetSeeButton?
public extension LetSee {
	var letSeeButton: LetSeeButton? {
		guard let strongReferenceLetSeeButton = strongReferenceLetSeeButton else {
			print("You need to call `letSee.insertLetSeeButton(on:window)` function first.")
			return nil
		}

		return strongReferenceLetSeeButton
	}

	func insertLetSeeButton(on window: UIWindow) {
		let button = LetSeeButton(letSee: self)
		 DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
			 button.showButton(on: window)
		 }
		strongReferenceLetSeeButton = button
	}
}

public final class LetSeeButton {
	private lazy var serverWindow: UIWindow = {
		if #available(iOS 13.0, *) {
			let windowScene =  mainWindow?.windowScene
			if let windowScene = windowScene {
				return UIWindow(windowScene: windowScene)

			}
			return UIWindow(frame:  UIScreen.main.bounds)
		} else {
			return UIWindow(frame:  UIScreen.main.bounds)
		}

	}()

	private weak var mainWindow: UIWindow? = nil
	@objc private func openInMobile() {
		guard let letSee = letSee else {
			print("Letsee object is removed from memory, you need to keep a strong reference to the LetSee object")
			return
		}
		let hosting = UIHostingController(rootView: LetSeeView(letSee: letSee))
		mainWindow?.rootViewController?.present(hosting, animated: true)
	}
	private weak var letSee: LetSee?
	public init(letSee: LetSee) {
		self.letSee = letSee
	}

	public func showButton(on window: UIWindow) {
		self.mainWindow = window
		createAButtonForInAppWeb()
	}
	private var button =  UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 150, width: 50, height: 50))

	private func createAButtonForInAppWeb() {
		button.addTarget(self, action: #selector(self.openInMobile), for: .touchUpInside)

		button.backgroundColor = .systemGray
		button.layer.cornerRadius = 12
		mainWindow?.addSubview(button)
		mainWindow?.bringSubviewToFront(button)
	   let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
		button.isUserInteractionEnabled = true
		button.addGestureRecognizer(panGesture)
		button.setTitle("See", for: .normal)
	}

	@objc func draggedView(_ sender:UIPanGestureRecognizer){
		let translation = sender.translation(in: self.mainWindow)
		button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
		sender.setTranslation(CGPoint.zero, in: self.mainWindow)
	}

}
