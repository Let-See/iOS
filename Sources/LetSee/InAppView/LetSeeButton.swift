//
//  LetSeeButton.swift
//  
//
//  Created by Farshad Macbook M1 Pro on 7/26/22.
//

import Foundation
import SafariServices
import SwiftUI
import LetSee

extension LetSeeProtocol {
    @discardableResult
    func addLetSeeButton(on window: UIWindow) -> LetSeeButton {
        let button = LetSeeButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            button.showButton(on: window)
        }
        return button
    }
}

public final class LetSeeButton {
    private weak var mainWindow: UIWindow? = nil
    @objc private func openInMobile() {
        let hosting = UIHostingController(rootView: LetSeeView(viewModel: LetSeeViewModel()))
        mainWindow?.rootViewController?.present(hosting, animated: true)
    }
    public func showButton(on window: UIWindow) {
        self.mainWindow = window
        createAButtonForInAppWeb()
    }
    private(set) public var button =  UIButton(frame: CGRect(x: UIScreen.main.bounds.width - 70, y: UIScreen.main.bounds.height - 150, width: 50, height: 50))
    private var badgeView = UIButton()
    @MainActor
    public var badge: String? {
        set {
            self.setBadge(newValue)
        }
        get {
            badgeView.titleLabel?.text
        }
    }

    private func createAButtonForInAppWeb() {
        button.addTarget(self, action: #selector(self.openInMobile), for: .touchUpInside)
        
        button.backgroundColor = .label
        button.layer.cornerRadius = 12
        button.setTitleColor(.systemBackground, for: .normal)
        mainWindow?.addSubview(button)
        mainWindow?.bringSubviewToFront(button)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        button.isUserInteractionEnabled = true
        button.addGestureRecognizer(panGesture)
        button.setTitle("See", for: .normal)
        badgeView = createBadge()
        button.addSubview(badgeView)
        badgeView.center = .init(x: 0, y: 0)
    }

    private func createBadge() -> UIButton {
        let btn = UIButton()
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.backgroundColor = .label //UIColor(red: 0.18, green: 0.31, blue: 0.31, alpha: 1.00)
        btn.setTitle("0", for: .normal)
        btn.clipsToBounds = true
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.frame.size = .init(width: 30, height: 30)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = btn.frame.height / 2
        return btn
    }

    private func setBadge(_ string: String?) {
        badgeView.setTitle(string, for: .normal)
        badgeView.isHidden = string == nil
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.mainWindow)
        button.center = CGPoint(x: button.center.x + translation.x, y: button.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.mainWindow)
    }
}
