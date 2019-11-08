//
//  JSLTransitionLib
//

import UIKit

//----------------------------------------------------------

extension UIViewController {

    /// Store the navigationTransitioningDelegate
    public var navigationTransitioningDelegateS: NavigationTransitioningDelegate? {
        get {
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.navigationTransitioningDelegateS) as? NavigationTransitioningDelegate else {
                return nil
            }
            return  value
        }

        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.navigationTransitioningDelegateS, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

}

//----------------------------------------------------------

/// 导航转场控制协议
protocol NavigationTransitioningProtocol {

    /// 是否允许交互 pop, 默认 true
    var isInteractivePopEnabled: Bool { set get }

    /// 是否正在交互 pop
    var isInteractivePoping: Bool { get }

    /// 是否正在过渡动画
    var isNavigationTransitioning: Bool { get }

    /// 根据 operation 转场动画, nil 为默认动画, 可重载返回定义转场动画
    ///
    /// - Parameters:
    ///   - forOperation: 转场方式
    ///   - interactive: 是否为交互 pop
    /// - Returns: 转场动画, nil 为默认
    func navigationControllerAnimatedTransitioning(forOperation: UINavigationController.Operation,
                                                   interactive: Bool) -> BasicViewControllerAnimatedTransitioning?

    /// 开始收到交互手势
    ///
    /// - Parameter touch: 手势
    /// - Returns: 返回 false 取消交互, 默认 true
    func interactivePopGestureShouldReceive(touch: UITouch) -> Bool

    /// 开始移动手势
    ///
    /// - Parameter translation: 位移
    /// - Returns: 返回 false 取消交互, 默认 true
    func interactivePopGestureShouldBegin(translation: CGPoint) -> Bool

    /// 通过位移和开始位置，计算 pop 的进度
    ///
    /// - Parameters:
    ///   - translation: 位移
    ///   - startPoint: 开始位置
    /// - Returns: 完成进度 0 ~ 1
    func navigationInteractivePopCompletePercent(currentProgress: CGFloat,
                                                 translation: CGPoint,
                                                 startPoint: CGPoint) -> CGFloat

    /// 开始
    func startInteractivePop()
    /// 完成
    func finishInteractivePop()
    /// 取消
    func cancleInteractivePop()

    /// 用于 NavigationControllerTransitioning 的子视图控制器，默认为 nil
    func childViewControllerForNavigationControllerTransitioning() -> UIViewController?
    
}

//----------------------------------------------------------

extension UIViewController: NavigationTransitioningProtocol {

    @objc open var isInteractivePopEnabled: Bool {
        get {
            let popEnable = childViewControllerForNavigationControllerTransitioning()?.isInteractivePopEnabled
            guard let value = objc_getAssociatedObject(self, &AssociatedKeys.isInteractivePopEnabled) as? Bool else {
                return popEnable ?? true
            }
            return popEnable ?? value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &AssociatedKeys.isInteractivePopEnabled, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public var isInteractivePoping: Bool {
        guard let delegate = self.navigationTransitioningDelegate else {
            return false
        }
        return delegate.isInteractivePoping
    }

    public var isNavigationTransitioning: Bool {
        guard let delegate = self.navigationTransitioningDelegate else {
            return false
        }
        return delegate.isTransitioning
    }

    /// 当前视图控制器的转场代理
    var navigationTransitioningDelegate: NavigationTransitioningDelegate? {
        var navigation: UINavigationController?
        if let navi = self as? UINavigationController {
            navigation = navi
        } else {
            navigation = self.navigationController
        }

        guard let transitioningDelegate = navigation?.delegate as? NavigationTransitioningDelegate else {
            return self.parent?.navigationTransitioningDelegate
        }
        return transitioningDelegate
    }

    @objc open func navigationControllerAnimatedTransitioning(forOperation: UINavigationController.Operation, interactive: Bool) -> BasicViewControllerAnimatedTransitioning? {
        return self.childViewControllerForNavigationControllerTransitioning()?.navigationControllerAnimatedTransitioning(forOperation: forOperation, interactive: interactive)
    }

    @objc open func interactivePopGestureShouldReceive(touch: UITouch) -> Bool {
        guard let should =
            self.childViewControllerForNavigationControllerTransitioning()?
                .interactivePopGestureShouldReceive(touch:touch) else {
                    return true
        }
        return should
    }

    @objc open func interactivePopGestureShouldBegin(translation: CGPoint) -> Bool {
        guard let should =
            self.childViewControllerForNavigationControllerTransitioning()?
                .interactivePopGestureShouldBegin(translation:translation) else {
                    return true
        }
        return should
    }

    @objc open func navigationInteractivePopCompletePercent(currentProgress: CGFloat,
                                                            translation: CGPoint,
                                                            startPoint: CGPoint) -> CGFloat {
        if let childViewController = self.childViewControllerForNavigationControllerTransitioning() {
            return childViewController.navigationInteractivePopCompletePercent(currentProgress: currentProgress, translation: translation, startPoint:startPoint)
        } else {
            return translation.x / self.view.bounds.width
        }
    }

    @objc open func startInteractivePop() {
        self.childViewControllerForNavigationControllerTransitioning()?.startInteractivePop()
    }

    @objc open func finishInteractivePop() {
        self.childViewControllerForNavigationControllerTransitioning()?.finishInteractivePop()
    }

    @objc open func cancleInteractivePop() {
        self.childViewControllerForNavigationControllerTransitioning()?.cancleInteractivePop()
    }

    @objc open func childViewControllerForNavigationControllerTransitioning() -> UIViewController? {
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController
        }
        return nil
    }

}

//----------------------------------------------------------

