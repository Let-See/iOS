//
//  LetSeeWindow.swift
//  TestApp
//
//  Created by Farshad Jahanmanesh on 03/01/2023.
//

import Foundation
import LetSee
import UIKit
import LetSee
public class LetSeeWindow: UIWindow {
    private var letSeeButton: LetSeeButton?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLetSee()
    }

    private func prepareLetSee() {
        self.windowLevel = UIWindow.Level.alert + 1
        self.isHidden = false
        self.makeKeyAndVisible()
        self.backgroundColor = .clear
        self.rootViewController = UIViewController()
        letSeeButton = LetSee.shared.addLetSeeButton(on: self)

        func collectNumber(from string: String) -> Int? {
            return Int(string.components(separatedBy: CharacterSet.decimalDigits.inverted).joined())
        }
        LetSee.shared.onMockStateChanged = { [weak letSeeButton] isMockActive in
            letSeeButton?.button.backgroundColor = isMockActive ? UIColor(red: 0.85, green: 0.65, blue: 0.13, alpha: 1.00) : .label
        }
        LetSee.shared.interceptor.onRequestAdded = { [weak letSeeButton] _ in
            Task.detached { @MainActor in
                letSeeButton?.badge = "\(LetSee.shared.interceptor._requestQueue.count)"
            }
        }

        LetSee.shared.interceptor.onRequestRemoved = { [weak letSeeButton] _ in
            Task.detached { @MainActor in
                let number = LetSee.shared.interceptor._requestQueue.count
                guard number > 0 else {
                    letSeeButton?.badge = nil
                    return
                }
                letSeeButton?.badge = "\(number)"
            }
        }
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        prepareLetSee()
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let letSeeButton else {
            return false
        }
        if self.rootViewController?.presentedViewController != nil {
            return true
        } else {
            return letSeeButton.button.frame.contains(point)
        }
    }
}
