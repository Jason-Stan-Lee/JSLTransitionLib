//
//  BasicTransitioning
//

import UIKit

/// 转场类型
///
/// - dismiss: 模态消失
/// - presented: 被模态推出
/// - presentTo: 模态推出其他视图
/// - none: 无转场
@objc public enum ModalTransitioningType: Int {
    case dismiss, presented, presentTo, none

    /// 是否支持手势交互
    func supportInteractive() -> Bool {
        return self == .dismiss || self == .presentTo
    }
}

extension UIViewController {

    /// Store the presentationTransitioningDelegate
    @objc
    public var presentationTransitioningDelegateS: ViewControllerTransitionDelegate? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.presentationTransitioningDelegateS) as? ViewControllerTransitionDelegate else {
                return nil
            }
            return  value
        }

        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.presentationTransitioningDelegateS, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

protocol ViewControllerTransitionProtocol {

    /// 是否允许交互 Dismiss，默认 true
    var isInteractiveDismissEnable: Bool { get set }
    /// 是否允许交互 Present to 新页面，默认 false
    var isInteractivePresentToEnable: Bool { get set }
    
    /// 是否正在 Dismiss 交互
    var isInteractiveDismissing: Bool { get }
    /// 是否正在交互 Present to 新页面
    var isInteractivePresentTo: Bool { get }

    /// 是否正在转场
    var isTransitioning: Bool { get }

    /// 转场动画，nil 则为默认
    func viewControllerAnimatedTransitioning(for transitionType: ModalTransitioningType) -> BasicViewControllerAnimatedTransitioning?

    /// UIPresentationController, nil 则为默认
    func presentationController(for presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?

    /// 开始接收 Touch，返回 false 取消
    func interactiveTransitionGestureShouldReceive(touch: UITouch) -> Bool
    /// 转场类型类型，禁止转场返回 TransitioningType.none
    func interactiveTransitionType(for location: CGPoint, translation: CGPoint) -> ModalTransitioningType

    /// 位移和起始位置，返回进度
    func interactiveTransitionCompletePercent(for transitionType: ModalTransitioningType,
                                              currentProcess: CGFloat,
                                              location: CGPoint,
                                              translation: CGPoint) -> CGFloat

    /// 根据 currentProcess 等判断交互转场是否需要中断，默认为 false。即交互手势尚未结束时，是否强制中断交互控制
    func interactiveTransitionShouldInterrupt(for transitionType: ModalTransitioningType,
                                              currentProcess: CGFloat) -> Bool
    
    /// 交互模态推出的视图控制器
    func viewControllerForInteractivePresentTo() -> UIViewController?

    /// 开始
    func startInteractive(for transitionType: ModalTransitioningType)
    /// 完成
    func finishInteractive(for transitionType: ModalTransitioningType)
    /// 取消
    func cancelInteractive(for transitionType: ModalTransitioningType)

    /// 与转场交互手势冲突时，是否可以同时进行
    func interactiveGestureRecognizer(shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool

    /// 用于 ViewControllerTransition 的子视图控制器，默认为 nil
    func childViewControllerForViewControllerTransitioning() -> UIViewController?

}

extension UIViewController: ViewControllerTransitionProtocol {

    @objc open var isInteractivePresentToEnable: Bool {
        get {
            let presentEnable = childViewControllerForViewControllerTransitioning()?.isInteractivePresentToEnable
            guard let value = objc_getAssociatedObject(childViewControllerForViewControllerTransitioning() ?? self, &AssociatedKeys.isInteractivePresentToEnable) as? Bool else {
                return presentEnable ?? false
            }
            return presentEnable ?? value
        }

        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.isInteractivePresentToEnable, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var isInteractivePresentTo: Bool {
        guard let transitioningDelegate = viewControllerTransitioningDelegate else {
            return false
        }
        return transitioningDelegate.isInteractivePresentTo
    }

    /// Current transitioningDelegate
    var viewControllerTransitioningDelegate: ViewControllerTransitionDelegate? {
        // 被模态推出
        if self.presentingViewController != nil {
            guard let delegate = self.transitioningDelegate as? ViewControllerTransitionDelegate else {
                return self.parent?.viewControllerTransitioningDelegate
            }
            return delegate
        } else {
            return self.presentedViewController?.viewControllerTransitioningDelegate
        }
    }

    @objc open var isInteractiveDismissEnable: Bool {
        get {
            let dismissEnable = childViewControllerForViewControllerTransitioning()?.isInteractiveDismissEnable
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isInteractiveDismissEnable) as? Bool else {
                return dismissEnable ?? true
            }
            return dismissEnable ?? value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.isInteractiveDismissEnable, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var isInteractiveDismissing: Bool {
        guard let transitioningDelegate = viewControllerTransitioningDelegate else {
            return false
        }
        return transitioningDelegate.isInteractiveDismissing
    }

    public var isTransitioning: Bool {
        guard let transitioningDelegate = viewControllerTransitioningDelegate else {
            return false
        }
        return transitioningDelegate.isTransitioning
    }

    /// Custom Animator for the transitionType
    @objc open func viewControllerAnimatedTransitioning(for transitionType: ModalTransitioningType) -> BasicViewControllerAnimatedTransitioning? {
        return childViewControllerForViewControllerTransitioning()?.viewControllerAnimatedTransitioning(for: transitionType)
    }


    /// Called when InteractivePresentTo trigered
    ///
    /// - Returns: the viewController for presented
    @objc open func viewControllerForInteractivePresentTo() -> UIViewController? {
        return childViewControllerForViewControllerTransitioning()?.viewControllerForInteractivePresentTo()
    }

    // UIPresentationController For custom Animator
    @objc open func presentationController(for presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return childViewControllerForViewControllerTransitioning()?.presentationController(for: presented, presenting: presenting, source: source)
    }

    // Return False if touched in the location which you did NOT want to triger ANY Transition
    @objc open func interactiveTransitionGestureShouldReceive(touch: UITouch) -> Bool {
        return childViewControllerForViewControllerTransitioning()?.interactiveTransitionGestureShouldReceive(touch: touch) ?? true
    }

    // Return the TransitioningType which you want to triger
    @objc open func interactiveTransitionType(for location: CGPoint, translation: CGPoint) -> ModalTransitioningType {

        if let type = childViewControllerForViewControllerTransitioning()?.interactiveTransitionType(for: location, translation: translation) {
            return type
        }

        if abs(translation.x) < abs(translation.y) {
            if translation.y > 0  {
                return .dismiss
            }
            return .presentTo
        }
        return .none
    }

    // Fractional process for interactive transition
    @objc open func interactiveTransitionCompletePercent(for transitionType: ModalTransitioningType,
                                                         currentProcess: CGFloat,
                                                         location: CGPoint,
                                                         translation: CGPoint) -> CGFloat {

        if let childVC = childViewControllerForViewControllerTransitioning() {
            return childVC.interactiveTransitionCompletePercent(for: transitionType,
                                                                currentProcess: currentProcess,
                                                                location: location,
                                                                translation: translation)
        }

        switch transitionType {
        case .dismiss:
            return translation.y / self.view.bounds.height
        case .presentTo:
            return -translation.y / self.view.bounds.height
        default:
            return 0
        }
    }

    // should interrupt the interactive gesture depends on currentProcess
    @objc open func interactiveTransitionShouldInterrupt(for transitionType: ModalTransitioningType, currentProcess: CGFloat) -> Bool {
        return childViewControllerForViewControllerTransitioning()?.interactiveTransitionShouldInterrupt(for: transitionType, currentProcess: currentProcess) ?? false
    }

    // Callback interactive transition start
    @objc open func startInteractive(for transitionType: ModalTransitioningType) {
        childViewControllerForViewControllerTransitioning()?.startInteractive(for: transitionType)
    }

    // Callback interactive transition finished
    @objc open func finishInteractive(for transitionType: ModalTransitioningType) {
        childViewControllerForViewControllerTransitioning()?.finishInteractive(for: transitionType)
    }

    // Callback interactive transition cancelled
    @objc open func cancelInteractive(for transitionType: ModalTransitioningType) {
        childViewControllerForViewControllerTransitioning()?.cancelInteractive(for: transitionType)
    }

    // Simultaneously gestureRecognizers if return True
    @objc open func interactiveGestureRecognizer(shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return childViewControllerForViewControllerTransitioning()?.interactiveGestureRecognizer(shouldRecognizeSimultaneouslyWith: otherGestureRecognizer) ?? (
            (otherGestureRecognizer as? UIPanGestureRecognizer == nil &&
                otherGestureRecognizer as? UISwipeGestureRecognizer == nil))
    }

    @objc public func childViewControllerForViewControllerTransitioning() -> UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController
        }

        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController
        }
        return nil
    }
    
}

//----------------------------------------------------------

