//
//  FirstViewController.swift
//  JSLTransitionLib_Example
//
//  Created by JasonLee on 2019/4/28.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import JSLTransitionLib

class FirstViewController: UIViewController {

    var type: DemoType = .normal

    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("NEXT", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(presentSecondViewController), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .orange
        if type == .presentTo {
            self.isInteractivePresentToEnable = true
        } else {
            view.addSubview(nextButton)
            nextButton.frame = CGRect(x: 100, y: 200, width: 100, height: 32)
        }

        if type == .semi {
            self.preferredContentSize = CGSize(width: view.bounds.height, height: view.bounds.height * 0.4)
        }

        // Do any additional setup after loading the view.
    }

    @objc
    private func presentSecondViewController() {
        let secondVC = secondViewController()
        self.present(secondVC, animated: true, completion: nil)
    }

    private func secondViewController() -> UIViewController {
        let secondViewController = SecondViewController()
        secondViewController.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: secondViewController)
        return secondViewController
    }

}


// MARK: - CustomTransitioning
extension FirstViewController {

    // Return False if touched in the location which you did NOT want to triger ANY Transition
    override func interactiveTransitionGestureShouldReceive(touch: UITouch) -> Bool {
        return true
    }

    // return the TransitioningType which you want to triger
    override func interactiveTransitionType(for location: CGPoint, translation: CGPoint) -> ModalTransitioningType {
        return super.interactiveTransitionType(for: location, translation: translation)
    }

    // Simultaneously if return True
    override func interactiveGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer, for transitionType: ModalTransitioningType) -> Bool {
        return super.interactiveGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer, for: transitionType)
    }

    // Fractional process for interactive transition
    override func interactiveTransitionCompletePercent(for transitionType: ModalTransitioningType, location: CGPoint, translation: CGPoint) -> CGFloat {
        return super.interactiveTransitionCompletePercent(for: transitionType, location: location, translation: translation)
    }

    override func startInteractive(for transitionType: ModalTransitioningType) {
        // interactive transition start
    }

    override func finishInteractive(for transitionType: ModalTransitioningType) {
        // interactive transition finished
    }

    override func cancelInteractive(for transitionType: ModalTransitioningType) {
        // interactive transition cancelled
    }

    // TransitioningAnimator
    override func viewControllerAnimatedTransitioning(for transitionType: ModalTransitioningType) -> BasicViewControllerAnimatedTransitioning? {

        // override to Return custom Animator for each transitionType
        // The Animator must be a subclass of 'BasicViewControllerAnimatedTransitioning'
        // return CustomAnimator(type: transitionType)

        return super.viewControllerAnimatedTransitioning(for: transitionType)
    }

    // Custom PresentionController
    override func presentationController(for presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        if type == .semi {
            return SemiPresentationController(presentedViewController: presented, presenting: presenting)
        }
        return nil
    }

    override func viewControllerForInteractivePresentTo() -> UIViewController? {
        return secondViewController()
    }

}
