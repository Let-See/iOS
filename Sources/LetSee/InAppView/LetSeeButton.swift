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
        containerStackView.addArrangedSubview(actionButton)
        containerStackView.addArrangedSubview(scenarioStackView)
        DispatchQueue.main.async {
            self.containerView.layoutSubviews()
            self.containerView.layoutIfNeeded()
        }
        containerView.addSubview(containerStackView)
        containerStackView.widthAnchor
            .constraint(equalTo: containerView.widthAnchor, constant: -8)
            .isActive = true
        containerStackView.heightAnchor
            .constraint(equalTo: containerView.heightAnchor, constant: -8)
            .isActive = true

        containerStackView.centerXAnchor
            .constraint(equalTo: containerView.centerXAnchor)
            .isActive = true
        containerStackView.centerYAnchor
            .constraint(equalTo: containerView.centerYAnchor)
            .isActive = true

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.draggedView(_:)))
        containerView.addGestureRecognizer(panGesture)

        let vc = UIViewController()
        mainWindow?.rootViewController = vc
        vc.view.addSubview(containerView)
        vc.view.bringSubviewToFront(containerView)
        DispatchQueue.main.async {
            self.updateContainerPosition()
        }
    }
    private var containerViewPosition: CGPoint = .init(x: 70, y: UIScreen.main.bounds.height - 150)
    private func updateContainerPosition() {
        self.containerView.frame.origin = containerViewPosition
    }
    lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: 50).isActive = true
        btn.widthAnchor.constraint(equalToConstant: 50).isActive = true
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.backgroundColor = .black
        btn.setTitle("See", for: .normal)
        btn.clipsToBounds = true
        btn.layer.cornerRadius = 12
        btn.frame.size = .init(width: 50, height: 50)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(self.openInMobile), for: .touchUpInside)
        btn.addSubview(badgeView)
        badgeView.center = .init(x: 0, y: 0)
        return btn
    }()

    private func setBadge(_ string: String?) {
        badgeView.setTitle(string, for: .normal)
        badgeView.isHidden = string == nil
    }

    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.mainWindow)
        containerViewPosition = CGPoint(x: containerViewPosition.x + translation.x,
                                        y: containerViewPosition.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.mainWindow)
        updateContainerPosition()
    }

    lazy var containerView: UIView = {
        let view = UIView(frame: .init(origin: .init(x: 70, y: UIScreen.main.bounds.height - 150), size: .init(width: 50, height: 50)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    var containerWidthConstraint: NSLayoutConstraint?
    lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        containerWidthConstraint = stackView.widthAnchor.constraint(equalToConstant: 50)
        containerWidthConstraint?.isActive = true
        return stackView
    }()

    lazy var badgeView: UIButton = {
        let btn = UIButton()
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.backgroundColor = .label
        btn.setTitle("0", for: .normal)
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.frame.size = .init(width: 30, height: 30)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = btn.frame.height / 2
        return btn
    }()

    lazy var scenarioStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.font = .boldSystemFont(ofSize: 13)
        title.textColor = .black

        let subTitle = UILabel()
        subTitle.translatesAutoresizingMaskIntoConstraints = false
        subTitle.font = .systemFont(ofSize: 13)
        subTitle.textColor = .label
        stackView.addArrangedSubview(title)
        stackView.addArrangedSubview(subTitle)
        return stackView
    }()

    @MainActor
    func setScenario(_ scenario: Scenario?) {
        defer {
            UIView.animate(withDuration: 0.3) {
                self.containerView.setNeedsLayout()
                self.containerView.layoutIfNeeded()
                self.containerView.superview?.layoutIfNeeded()
                self.updateContainerPosition()
            }
        }
        guard let scenario else {
            scenarioStackView.isHidden = true
            self.containerWidthConstraint?.constant = 50
            return
        }
        var width: CGFloat = 0
        if let label = self.scenarioStackView.subviews[0] as? UILabel {
            label.attributedText = appendScenarioIcon(scenario.name)
            width = label.sizeThatFits(.zero).width
        }

        if let label = self.scenarioStackView.subviews[1] as? UILabel {
            label.attributedText = attributedText(withString: "Next Response: \(scenario.currentStep?.name ?? "")", boldString: "\(scenario.currentStep?.name ?? "")", font: .systemFont(ofSize: 13))
            width = max(width, label.sizeThatFits(.zero).width)
        }
        self.actionButton.layoutIfNeeded()
        self.scenarioStackView.isHidden = false
        self.containerWidthConstraint?.constant = width + self.actionButton.frame.width + containerStackView.spacing
    }

    func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }

    func appendScenarioIcon(_ string: String) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "s.square.fill")?.withTintColor(.black)

        let fullString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: imageAttachment))
        fullString.append(.init(string: ("  " + string)))
    
        return fullString
    }
}

