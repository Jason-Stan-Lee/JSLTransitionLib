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
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return button
    }()

    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.text = "下滑返回菜单"
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tipsLabel)
        tipsLabel.frame = CGRect(x: 0, y: 100, width: 320, height: 32)

        view.backgroundColor = .orange
        switch type {
        case .presentTo:
            isInteractivePresentToEnable = true
            tipsLabel.text = "下滑返回菜单，上滑推出新页面"
        case .semi:
            preferredContentSize = CGSize(width: view.bounds.height, height: view.bounds.height * 0.4)
        default:
            view.addSubview(nextButton)
            nextButton.frame = CGRect(x: 100, y: 200, width: 100, height: 32)
        }

        // Do any additional setup after loading the view.
    }

    @objc
    private func nextButtonAction() {
        let secondVC = secondViewController()
        if type == .normal {
            self.present(secondVC, animated: true, completion: nil)
        } else if type == .navigation {
            self.navigationController?.pushViewController(secondVC, animated: true)
        }
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
        // eg: pull down when the scroll view is scrolling to top.
        // return .dismiss
    }

    // Simultaneously if return True
    override func interactiveGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer, for transitionType: ModalTransitioningType) -> Bool {
        return super.interactiveGestureRecognizer(gestureRecognizer, shouldRecognizeSimultaneouslyWith: otherGestureRecognizer, for: transitionType)
    }

    // Fractional process for interactive transition
    override func interactiveTransitionCompletePercent(for transitionType: ModalTransitioningType,
                                                       currentProgress: CGFloat,
                                                       location: CGPoint,
                                                       translation: CGPoint) -> CGFloat {
        return super.interactiveTransitionCompletePercent(for: transitionType,
                                                          currentProgress: currentProgress,
                                                          location: location,
                                                          translation: translation)
        /*
         eg: pull down when the scroll view is scrolling to top.
         
         let offsetY = scrollView.contentOffset.y
         scrollView.scrollEnabled = true
         percent = super.interactiveTransitionCompletePercent(for: transitionType,
                                                              currentProgress: currentProgress,
                                                              location: location,
                                                              translation: translation)
         if offsetY <= 0,
            percent > 0 {
             return percent
         }
         if currentProgress < 1,
            currentProgress > 0 {
             scrollView.scrollEnabled = false
             return percent
         }
         */
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
