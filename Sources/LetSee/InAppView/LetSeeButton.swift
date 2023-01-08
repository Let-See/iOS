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
    @MainActor @discardableResult
    func addLetSeeButton(on window: UIWindow) -> LetSeeButton {
        let button = LetSeeButton()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            button.showButton(on: window)
        }
        return button
    }
}

public extension LetSeeButton {
    struct Configuration {
        public let activeBackgroundColor: UIColor
        public let inactiveBackgroundColor: UIColor
        public let thinestPadding: CGFloat
        public let thickestPadding: CGFloat
        public let buttonSize: CGSize
        public let cornerRadius: CGFloat
        public let initialPosition: CGPoint
        init(activeBackgroundColor: UIColor = UIColor(red: 0.56, green: 0.66, blue: 0.31, alpha: 1.00),
             inactiveBackgroundColor: UIColor = .label,
             thinestPadding: CGFloat = 8,
             thickestPadding: CGFloat = 12,
             buttonSize: CGSize = CGSize(width: 50, height: 50),
             cornerRadius: CGFloat = 8,
             initialPosition: CGPoint = CGPoint(x: 24, y: UIScreen.main.bounds.height - 150)
        ) {
            self.activeBackgroundColor = activeBackgroundColor
            self.inactiveBackgroundColor = inactiveBackgroundColor
            self.thinestPadding = thinestPadding
            self.thickestPadding = thickestPadding
            self.buttonSize = buttonSize
            self.cornerRadius = cornerRadius
            self.initialPosition = initialPosition
        }
    }

    enum LetSeeButtonState {
        case active
        case inactive
        case activeWithScenario(Scenario)
    }
}

@MainActor
public final class LetSeeButton {
    init(_ options: LetSeeButton.Configuration = Configuration()) {
        self.options = options
    }
    var options: LetSeeButton.Configuration
    private weak var mainWindow: UIWindow? = nil
    @objc private func openInMobile() {
        let hosting = UIHostingController(rootView: LetSeeView(viewModel: LetSeeViewModel()))
        mainWindow?.rootViewController?.present(hosting, animated: true)
    }

    public func showButton(on window: UIWindow) {
        self.mainWindow = window
        createAButtonForInAppWeb()
    }

    public var badge: String? {
        set {
            self.setBadge(newValue)
        }
        get {
            badgeView.titleLabel?.text
        }
    }
    private var stackContainerViewWidthConstraint: NSLayoutConstraint?
    private var stackContainerViewHeightConstraint: NSLayoutConstraint?
    private func createAButtonForInAppWeb() {
        containerStackView.addArrangedSubview(actionButton)
        containerStackView.addArrangedSubview(scenarioStackView)
        DispatchQueue.main.async {
            self.containerView.layoutSubviews()
            self.containerView.layoutIfNeeded()
        }
        containerView.addSubview(containerStackView)
        stackContainerViewWidthConstraint = containerView.widthAnchor
            .constraint(equalTo: containerStackView.widthAnchor, constant: 0)
        stackContainerViewWidthConstraint!.isActive = true

        stackContainerViewHeightConstraint = containerView.heightAnchor
            .constraint(equalTo: containerStackView.heightAnchor, constant: 0)

        stackContainerViewHeightConstraint!.isActive = true

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
    private lazy var containerViewPosition: CGPoint = options.initialPosition
    private func updateContainerPosition() {
        self.containerView.frame.origin = containerViewPosition
    }
    private lazy var actionButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.heightAnchor.constraint(equalToConstant: options.buttonSize.width).isActive = true
        btn.widthAnchor.constraint(equalToConstant: options.buttonSize.height).isActive = true
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.backgroundColor = .black
        btn.setTitle("See", for: .normal)
        btn.clipsToBounds = true
        btn.frame.size = options.buttonSize
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.addTarget(self, action: #selector(self.openInMobile), for: .touchUpInside)
        btn.addSubview(badgeView)
        btn.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        btn.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        btn.layer.shadowOpacity = 1.0
        btn.layer.shadowRadius = 3.0
        btn.layer.masksToBounds = false
        btn.layer.cornerRadius = options.cornerRadius
        badgeView.topAnchor.constraint(equalTo: btn.topAnchor, constant: -(badgeView.frame.height / 2)).isActive = true
        badgeView.leadingAnchor.constraint(equalTo: btn.leadingAnchor, constant: -(badgeView.frame.width / 2)).isActive = true
        return btn
    }()

    private func setBadge(_ string: String?) {
        badgeView.setTitle(string, for: .normal)
        badgeView.isHidden = string == nil
        refreshViewLayout()
    }

    @objc
    private func draggedView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.mainWindow)
        containerViewPosition = CGPoint(x: containerViewPosition.x + translation.x,
                                        y: containerViewPosition.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.mainWindow)
        updateContainerPosition()
    }

    private lazy var containerView: UIView = {
        let view = UIView(frame: .init(origin: containerViewPosition, size: options.buttonSize))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = options.cornerRadius
        view.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        view.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        view.layer.shadowOpacity = 1.0
        view.layer.shadowRadius = 3.0
        view.layer.masksToBounds = false
        return view
    }()
    private var containerWidthConstraint: NSLayoutConstraint?
    private lazy var containerStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fill
        containerWidthConstraint = stackView.widthAnchor.constraint(equalToConstant: options.buttonSize.width)
        containerWidthConstraint?.isActive = true
        return stackView
    }()

    private lazy var badgeView: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitleColor(.systemBackground, for: .normal)
        btn.backgroundColor = .red
        btn.setTitle("0", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 12)
        btn.isHidden = true
        btn.isUserInteractionEnabled = false
        btn.frame.size = .init(width: 22, height: 22)
        btn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        btn.layer.cornerRadius = btn.frame.height / 2
        btn.widthAnchor.constraint(equalToConstant: btn.frame.size.width).isActive = true
        btn.heightAnchor.constraint(equalToConstant: btn.frame.size.height).isActive = true
        return btn
    }()

    private lazy var scenarioStackView: UIStackView = {
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

    private func updateContainerStackViewPaddings(_ state: LetSeeButtonState) {
        defer {
            refreshViewLayout()
        }
        switch state {
        case .activeWithScenario:
            self.stackContainerViewWidthConstraint?.constant = options.thickestPadding
            self.stackContainerViewHeightConstraint?.constant =  options.thickestPadding
        default:
            self.stackContainerViewWidthConstraint?.constant = options.thinestPadding
            self.stackContainerViewHeightConstraint?.constant = options.thinestPadding
        }
    }

    private func updateBackground(_ state: LetSeeButtonState) {
        switch state {
        case .inactive:
            self.containerView.backgroundColor = options.inactiveBackgroundColor

        default:
            self.containerView.backgroundColor = options.activeBackgroundColor
        }
    }

    @MainActor
    func updateState(to state: LetSeeButtonState) {
        updateBackground(state)
        updateContainerStackViewPaddings(state)
        switch state {
        case .activeWithScenario(let scenario):
            setScenario(scenario)
        default:
            setScenario(nil)
        }
    }

    // for future, we need to show a beautiful animation around the button
    private lazy var containerViewBackgroundGradient: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.frame = self.containerView.bounds
        gradient.colors = [
            options.inactiveBackgroundColor.cgColor,
            options.activeBackgroundColor.cgColor
        ]
        gradient.type = .radial
        gradient.startPoint = CGPoint(x:0.5, y:0.5)
        gradient.endPoint = CGPoint(x:1, y:1)
        return gradient
    }()

    private func toggleAnimatingContainerViewBackgroundColor(_ animate: Bool) {
        guard animate else {
            containerViewBackgroundGradient.removeAllAnimations()
            return
        }
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 5.0
        gradientChangeAnimation.toValue = [
            options.activeBackgroundColor.cgColor,
            options.inactiveBackgroundColor.cgColor
        ]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.autoreverses = true
        gradientChangeAnimation.repeatCount = 1000
        gradientChangeAnimation.isRemovedOnCompletion = false
        containerViewBackgroundGradient.add(gradientChangeAnimation, forKey: "colorChange")
    }

    private func refreshViewLayout() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.setNeedsLayout()
            self.containerView.layoutIfNeeded()
            self.containerView.superview?.layoutIfNeeded()
            self.updateContainerPosition()
        }
    }

    private func setScenario(_ scenario: Scenario?) {
        defer {
            refreshViewLayout()
        }
        guard let scenario else {
            scenarioStackView.isHidden = true
            self.containerWidthConstraint?.constant = options.buttonSize.width
            return
        }
        var width: CGFloat = 0
        if let label = self.scenarioStackView.subviews[0] as? UILabel {
            label.attributedText = appendScenarioIcon(scenario.name)
            label.clipsToBounds = false
            width = label.sizeThatFits(.zero).width
        }

        if let label = self.scenarioStackView.subviews[1] as? UILabel {
            label.attributedText = attributedText(withString: " Next Response: \(scenario.currentStep?.name ?? "")", boldString: "\(scenario.currentStep?.name ?? "")", font: .systemFont(ofSize: 13))
            width = max(width, label.sizeThatFits(.zero).width)
        }
        self.actionButton.layoutIfNeeded()
        self.scenarioStackView.isHidden = false
        self.containerWidthConstraint?.constant = width + self.actionButton.frame.width + containerStackView.spacing
    }

    private func attributedText(withString string: String, boldString: String, font: UIFont) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: string,
                                                     attributes: [NSAttributedString.Key.font: font])
        let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
        let range = (string as NSString).range(of: boldString)
        attributedString.addAttributes(boldFontAttribute, range: range)
        return attributedString
    }

    private func appendScenarioIcon(_ string: String) -> NSAttributedString {
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(systemName: "s.square.fill")?.withTintColor(.black)

        let fullString = NSMutableAttributedString(attributedString: NSAttributedString(attachment: imageAttachment))
        fullString.append(.init(string: (" " + string)))

        fullString.addAttributes([.baselineOffset: 2], range: NSRange(location: 1, length: fullString.length - 1))
        return fullString
    }

    public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        self.containerView.frame.contains(point)
    }

}

