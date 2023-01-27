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

/**
 A custom `UIWindow` subclass that displays a `LetSeeButton` and manages its state and behavior.
 */
public class LetSeeWindow: UIWindow {

    // MARK: - Properties

    /// The `LetSeeButton` object displayed in the window.
    private var letSeeButton: LetSeeButton?

    // MARK: - Initialization

    /**
     Initializes a new `LetSeeWindow` object with the specified frame.

     - Parameters:
       - frame: The frame for the window.
     */
    public override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLetSee()
    }

    /// A `Cancellable` object used to manage the subscriptions to the `LetSee` objects.
    private var disposeBag: [AnyCancellable] = []
    public override func layoutSubviews() {
        super.layoutSubviews()
        letSeeButton?.updateContainerPosition()
    }
    /**
     Performs setup for the `LetSeeWindow` object.
     */
    private func prepareLetSee() {
        self.windowLevel = UIWindow.Level.alert + 1
        self.isHidden = false
        self.makeKeyAndVisible()
        self.backgroundColor = .clear
        self.rootViewController = UIViewController()
        letSeeButton = LetSee.shared.addLetSeeButton(on: self)

        LetSee.shared.onMockStateChanged = { [weak letSeeButton] isMockActive in
            letSeeButton?.updateState(to: isMockActive ? .active : .inactive)
        }

        LetSee
            .shared
            .interceptor
            .scenario
            .receive(on: DispatchQueue.main)
            .sink {[weak letSeeButton] scenario in
                if let scenario {
                    letSeeButton?.updateState(to: .activeWithScenario(scenario))
                } else {
                    letSeeButton?.updateState(to: .active)
                }
            }
            .store(in: &disposeBag)

        LetSee
            .shared
            .interceptor
            .$_requestQueue
            .receive(on: DispatchQueue.main)
            .sink {[weak self] requests in
                let number = requests.count
                guard number > 0 else {
                    self?.letSeeButton?.badge = nil
                    if !LetSee.shared.interceptor.isScenarioActive {
                        self?.letSeeButton?.updateState(to: .active)
                    }

                    return
                }

                self?.letSeeButton?.badge = "\(number)"
                if !LetSee.shared.interceptor.isScenarioActive, let lastRequest = requests.last {
                    self?.letSeeButton?.updateState(to: .activeWithQuickAccess(lastRequest))
                    self?.letSeeButton?.onMockTapped = { mock in
                        LetSee.shared.interceptor.respond(request: lastRequest.request, with: mock)
                    }
                } else {
                    self?.letSeeButton?.onMockTapped = nil
                }
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
            return letSeeButton.point(inside: point, with: event)
        }
    }
}
