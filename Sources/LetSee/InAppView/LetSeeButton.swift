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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            button.showButton(on: window)
        }
        return button
    }
}

public extension LetSeeButton {
    /// The Configuration struct is used to store configuration options for the LetSeeButton object.
    struct Configuration {
        /// The background color of the button when it is in the active state. This is a UIColor object with a default value of **UIColor(red: 0.56, green: 0.66, blue: 0.31, alpha: 1.00)**.
        public let activeBackgroundColor: UIColor

        /// The background color of the button when it is in the inactive state. This is a UIColor object with a default value of **.label**.
        public let inactiveBackgroundColor: UIColor

        /// The minimum amount of padding to use around the button when it is in the active state. This is a CGFloat with a default value of **8**.
        public let thinestPadding: CGFloat

        /// The maximum amount of padding to use around the button when it is in the active state. This is a CGFloat with a default value of **12**.
        public let thickestPadding: CGFloat

        /// The size of the button. This is a CGSize with a default value of **CGSize(width: 50, height: 50)**.
        public let buttonSize: CGSize

        /// The corner radius of the button. This is a CGFloat with a default value of **8**.
        public let cornerRadius: CGFloat

        /// The initial position of the button on the screen. This is a CGPoint with a default value of ** CGPoint(x: 24, y: UIScreen.main.bounds.height - 150) **.
        public let initialPosition: CGPoint

        public typealias MockStyle = (backgroundColor: UIColor, foreColor: UIColor)
        public let successMockStyle: MockStyle
        public let failedMockStyle: MockStyle

        init(activeBackgroundColor: UIColor = UIColor(red: 0.56, green: 0.66, blue: 0.31, alpha: 1.00),
             inactiveBackgroundColor: UIColor = .label,
             thinestPadding: CGFloat = 8,
             thickestPadding: CGFloat = 12,
             buttonSize: CGSize = CGSize(width: 50, height: 50),
             cornerRadius: CGFloat = 8,
             initialPosition: CGPoint = CGPoint(x: 24, y: UIScreen.main.bounds.height - 150),
             successMockStyle: MockStyle = (UIColor(red: 0.10, green: 0.53, blue: 0.33, alpha: 1.00), .white),
             failedMockStyle: MockStyle = (UIColor(red: 0.44, green: 0.11, blue: 0.11, alpha: 1.00), .white)
        ) {
            self.activeBackgroundColor = activeBackgroundColor
            self.inactiveBackgroundColor = inactiveBackgroundColor
            self.thinestPadding = thinestPadding
            self.thickestPadding = thickestPadding
            self.buttonSize = buttonSize
            self.cornerRadius = cornerRadius
            self.initialPosition = initialPosition
            self.successMockStyle = successMockStyle
            self.failedMockStyle = failedMockStyle
        }
    }

    /// The LetSeeButtonState enum represents the different states that the LetSeeButton object can be in.
    /// The LetSeeButtonState enum is used to indicate the current state of the LetSeeButton object and to determine how the button should behave and be displayed.
    ///
    /// For example, if the LetSeeButtonState is set to .active, the button may be displayed with a different background color and padding than if the LetSeeButtonState is set to **`.inactive`**. If the LetSeeButtonState is set to **`.activeWithScenario`**,
    /// the button may be displayed with a badge indicating the associated **`Scenario`** and may behave differently when clicked.
    enum LetSeeButtonState {
        /// Indicates that LetSee is in the active state and is intercepting requests
        case active
        /// Indicates that LetSee  is in the inactive state and it does't capture any request
        case inactive
        /// Indicates that LetSee is in the active state and is following a particular ``Scenario``.
        case activeWithScenario(Scenario)
        case activeWithQuickAccess(LetSeeUrlRequest)
    }
}

@MainActor
public final class LetSeeButton {
    /**
     Initializes a new `LetSeeButton` object with the specified configuration options.

     You can use the init function to create a new LetSeeButton object and customize it to your liking by providing your own values for the Configuration options.
     For example, to create a LetSeeButton object with a red background color and a size of 100x100, you could use the following code:

            let button = LetSeeButton(Configuration(activeBackgroundColor: .red,
            buttonSize: CGSize(width: 100, height: 100)))

     - Parameters:
       - options: The configuration options for the button.
     */
    init(_ options: LetSeeButton.Configuration = Configuration()) {
        self.options = options
    }
    /// The Configuration struct is used to store configuration options for the LetSeeButton object.
    let options: LetSeeButton.Configuration
    private weak var mainWindow: UIWindow? = nil
    @objc private func openInMobile() {
        let hosting = UIHostingController(rootView: LetSeeView(viewModel: LetSeeViewModel()))
        mainWindow?.rootViewController?.present(hosting, animated: true)
    }
    /**
     Shows the button on the specified window.

     - Parameters:
       - window: The window on which to show the button.
    */
    public func showButton(on window: UIWindow) {
        self.mainWindow = window
        createAButtonForInAppWeb()
    }

    /**
     Sets the badge for the button.

     - Parameters:
       - badge: The badge to display on the button. If `nil`, the badge will be removed.
    */
    public var badge: String? {
        set {
            self.setBadge(newValue)
        }
        get {
            badgeView.titleLabel?.text
        }
    }

    public var onMockTapped: ((LetSeeMock) -> Void)?
    private var stackContainerViewWidthConstraint: NSLayoutConstraint?
    private var stackContainerViewHeightConstraint: NSLayoutConstraint?
    
    private func createAButtonForInAppWeb() {
        containerStackView.addArrangedSubview(actionButton)
        containerStackView.addArrangedSubview(scenarioStackView)
        containerStackView.addArrangedSubview(mocksQuickAccessStackView)
        mocksQuickAccessStackView.isHidden = true

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

        let vc = ContainerViewController()
        vc.willLayout = {[weak self] in
            self?.updateContainerPosition()
        }
        mainWindow?.rootViewController = vc
        vc.view.addSubview(containerView)
        vc.view.bringSubviewToFront(containerView)
        DispatchQueue.main.async {
            self.updateContainerPosition()
        }
    }

    private lazy var containerViewPosition: CGPoint = options.initialPosition
    @MainActor
    func updateContainerPosition() {
        self.containerView.frame.origin = self.containerViewPosition
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

    private lazy var mockCollectionStackView: UIStackView = {
        let mockCollection = UIStackView()
        mockCollection.axis = .horizontal
        mockCollection.distribution = .fill
        mockCollection.spacing = 8
        mockCollection.translatesAutoresizingMaskIntoConstraints = false
        return mockCollection
    }()

    private lazy var mocksQuickAccessStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually

        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: 13)
        titleLabel.textColor = .black
        titleLabel.lineBreakMode = .byTruncatingHead
        let mockCollection = mockCollectionStackView
        let scrollView = UIButtonScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false

        scrollView.addSubview(mockCollection)
        mockCollection.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        mockCollection.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        mockCollection.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor).isActive = true
        mockCollection.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        scrollView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(scrollView)

        return stackView
    }()

    func mockBadgeButton(mock: LetSeeMock) -> UIButton {
        let button = UIButton()
        button.setTitle(mock.name, for: .normal)

        switch mock {
        case .cancel, .error, .failure:
            button.backgroundColor = options.failedMockStyle.backgroundColor
            button.setTitleColor(options.failedMockStyle.foreColor, for: .normal)
        case .live, .success:
            button.backgroundColor = options.successMockStyle.backgroundColor
            button.setTitleColor(options.successMockStyle.foreColor, for: .normal)
        }
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = .init(top: 2, left: 4, bottom: 2, right: 4)
        button.sizeToFit()

        return button
    }

    private func updateContainerStackViewPaddings(_ state: LetSeeButtonState) {
        defer {
            refreshViewLayout()
        }
        switch state {
        case .activeWithScenario:
            self.stackContainerViewWidthConstraint?.constant = options.thickestPadding
            self.stackContainerViewHeightConstraint?.constant =  options.thickestPadding

        case .activeWithQuickAccess:
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
    /**
     Updates the state of the button.

     The **updateState** function updates the internal state of the button and changes the appearance and behavior of the button to match the new state. For example, if the state is set to **.active**,
     the button may be displayed with a different background color and padding than if the state is set to **.inactive**. If the state is set to **.activeWithScenario**,
     the button may be displayed with a badge indicating the associated Scenario and may behave differently when clicked.

     - Parameters:
       - state: The new state for the button.
       - scenario: The `Scenario` associated with the button, if applicable.
     */
    @MainActor
    func updateState(to state: LetSeeButtonState) {
        updateBackground(state)
        updateContainerStackViewPaddings(state)
        switch state {
        case .activeWithScenario(let scenario):
            setQuickAccess(for: nil)
            setScenario(scenario)
        case .activeWithQuickAccess(let mock):
            setScenario(nil)
            setQuickAccess(for: mock)
            break
        default:
            setScenario(nil)
            setQuickAccess(for: nil)
        }
    }

    private func setQuickAccess(for mock: LetSeeUrlRequest?) {

        mockCollectionStackView
            .arrangedSubviews
            .forEach({$0.removeFromSuperview()})

        guard let mock else {
            resetContainer()
            return
        }

        defer {
            refreshViewLayout()
        }
        var sizeOfMockBadge: CGFloat = 0
        mock.mocks.first(where: {$0.category == .specific})?.mocks.forEach { mock in
            let button = mockBadgeButton(mock: mock)
            mockCollectionStackView.addArrangedSubview(button)
            let size = button.sizeThatFits(.zero)
            button.mock = mock
            button.addTarget(self, action: #selector(mockBadgeButtonTapped(_:)), for: .touchUpInside)
            sizeOfMockBadge = sizeOfMockBadge + size.width
        }

        self.mocksQuickAccessStackView.isHidden = false
        (self.mocksQuickAccessStackView.arrangedSubviews[0] as? UILabel)?.text = mock.request.url?.path
        self.containerWidthConstraint?.constant = min(sizeOfMockBadge, UIScreen.main.bounds.width - 48)
    }

    @objc private func mockBadgeButtonTapped(_ sender: UIButton) {
        guard let mock = sender.mock else {
            return
        }
        onMockTapped?(mock)

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

    private func resetContainer() {
        defer {
            refreshViewLayout()
        }

        self.scenarioStackView.isHidden = true
        self.mocksQuickAccessStackView.isHidden = true
        self.containerWidthConstraint?.constant = options.buttonSize.width

    }
    private func setScenario(_ scenario: Scenario?) {
        guard let scenario else {
            resetContainer()
            return
        }

        defer {
            refreshViewLayout()
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
    /**
     Converts a point from the button's coordinate system to the window's coordinate system.

     The **point** function returns the converted point in the coordinate system of the window. This can be useful if you need to perform calculations or perform other operations on the point in the context of the window's coordinate system.

     For example, you could use the **point** function to determine the position of the button relative to the window or to perform hit tests on the button to determine whether it was clicked.
     - Parameters:
       - point: The point to convert.
     - Returns: The converted point in the window's coordinate system.
     */
    public func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        self.containerView.frame.contains(point)
    }
}

private var mockUnSafeReference: Int8 = 0
fileprivate extension UIButton {
    var mock: LetSeeMock? {
        set {
            objc_setAssociatedObject(self, &mockUnSafeReference, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
        get {
            guard let mock = objc_getAssociatedObject(self, &mockUnSafeReference) as? LetSeeMock else {
                return nil
            }

            return mock
        }
    }
}

fileprivate final class UIButtonScrollView: UIScrollView {
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view.isKind(of: UIButton.self) {
          return true
        }

        return super.touchesShouldCancel(in: view)
    }
}

final class ContainerViewController: UIViewController {
    var willLayout: (()->Void)?
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        willLayout?()
    }
}
