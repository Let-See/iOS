//
//  LetSeeWindow.swift
//  TestApp
//
//  Created by Farshad Jahanmanesh on 03/01/2023.
//

import Foundation
import LetSee
import UIKit
import Combine
public class LetSeeWindow: UIWindow {
    private var letSeeButton: LetSeeButton?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLetSee()
    }
    private var disposeBag: [AnyCancellable] = []
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
            letSeeButton?.containerView.backgroundColor = isMockActive ? UIColor(red: 1.00, green: 0.84, blue: 0.00, alpha: 1.00) : .label
        }

        LetSee
            .shared
            .interceptor
            .scenario
            .receive(on: DispatchQueue.main)
            .sink {[weak self] scenario in
                self?.letSeeButton?.setScenario(scenario)
            }
            .store(in: &disposeBag)

        LetSee
            .shared
            .interceptor
            .$_requestQueue
            .receive(on: DispatchQueue.main)
            .sink {[weak self] scenario in
                let number = LetSee.shared.interceptor._requestQueue.count
                guard number > 0 else {
                    self?.letSeeButton?.badge = nil
                    return
                }
                self?.letSeeButton?.badge = "\(number)"
            }
            .store(in: &disposeBag)
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
            return letSeeButton.containerView.frame.contains(point)
        }
    }
}
