//
//  JSLTransitionLib
//

import UIKit

/// 导航转场代理，维护和管理导航 (Push, Pop) 转场以及转场状态
public class NavigationTransitioningDelegate: NSObject {

    private var interactiveGestureRecognizer: UIPanGestureRecognizer?
    private var interactiveTransition: UIPercentDrivenInteractiveTransition?
    private var interactiveTopViewController: UIViewController?

    /// 是否正在交互弹出
    private(set) var isInteractivePoping: Bool = false
    /// 是否正在过渡动画
    private(set) var isTransitioning: Bool = false
    /// 导航控制器
    weak private(set) var navigationController: UINavigationController?

    // MARK: Life Cycle

    deinit {
        // 移除手势
        guard let interactiveGr = interactiveGestureRecognizer else {
            return
        }
        self.navigationController?.view.removeGestureRecognizer(interactiveGr)
    }

    public init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()

        // 添加手势
        let interactiveGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleInteractiveGesture(gestureRecognizer:)))
        interactiveGestureRecognizer.delegate = self
        navigationController.view.addGestureRecognizer(interactiveGestureRecognizer)
        // 设置代理
        navigationController.delegate = self
        self.interactiveGestureRecognizer = interactiveGestureRecognizer
    }

    // MARK: State Check

    /// 代理的有效性检查
    ///
    /// - Returns: 是否有效
    private func checkDelegate() -> Bool {

        if navigationController?.delegate === self {
            return true
        }

        // 移除手势
        interactiveGestureRecognizer?.removeTarget(self, action: #selector(handleInteractiveGesture(gestureRecognizer:)))
        if let interactiveGr = interactiveGestureRecognizer {
            self.navigationController?.view.removeGestureRecognizer(interactiveGr)
            interactiveGestureRecognizer = nil
        }

        // 代理已经更改，BasicNavigationTransitioningDelegate 失效, 清空 context
        navigationController = nil
        interactiveTopViewController = nil

        return false
    }

    // MARK: Actions

    /// 转场交互手势处理
    ///
    /// - Parameter gestureRecognizer: 交互手势
    @objc
    private func handleInteractiveGesture(gestureRecognizer: UIPanGestureRecognizer) {
        guard let navi = navigationController else {
            return
        }
        let state = gestureRecognizer.state

        if state == .began {
            if !checkDelegate() {
                return
            }

            interactiveTopViewController = navi.topViewController
            interactiveTransition = UIPercentDrivenInteractiveTransition()
            interactiveTransition?.completionCurve = .linear
            isInteractivePoping = true

            navi.popViewController(animated: true)

            // 通知开始手势 Pop
            interactiveTopViewController?.startInteractivePop()
        } else {

            guard let topViewController = interactiveTopViewController else {
                gestureRecognizer.setTranslation(CGPoint.zero, in: navi.view)
                return
            }

            let locationPoint = gestureRecognizer.location(in: navi.view)
            let translation   = gestureRecognizer.translation(in: navi.view)
            let currentProgress = interactiveTransition?.percentComplete ?? 0
            // 完成比例
            var fraction = topViewController.navigationInteractivePopCompletePercent(currentProgress: currentProgress,
                                                                                     translation: translation,
                                                                                     startPoint: locationPoint) + (currentProgress)
            fraction = max(min(fraction, 1), 0)
            if state == .changed {
                interactiveTransition?.update(fraction)
            } else {
                // 滑动速度
                let velocity = gestureRecognizer.velocity(in: navi.view)
                // 加上速度，与速度正比
                fraction += topViewController.navigationInteractivePopCompletePercent(currentProgress: fraction, translation: velocity,
                                                                                      startPoint: locationPoint)

                // 完成
                if state == .ended && fraction >= 0.5 {
                    interactiveTransition?.finish()
                    topViewController.finishInteractivePop()
                } else { // 取消
                    interactiveTransition?.cancel()
                    topViewController.cancleInteractivePop()
                }

                interactiveTransition = nil
                interactiveTopViewController = nil
                isInteractivePoping = false
            }

            gestureRecognizer.setTranslation(CGPoint.zero, in: navi.view)
        }
    }

}

extension NavigationTransitioningDelegate: BasicViewControllerAnimatedTransitioningDelegate {

    public func viewControllerAnimatedTransitioning(_ transitioning: BasicViewControllerAnimatedTransitioning,
                                             didEndTransitioning completed: Bool) {
        isTransitioning = false
    }

}

extension NavigationTransitioningDelegate: UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // otherGestureRecognizer 是否需要失败
        if gestureRecognizer == interactiveGestureRecognizer {
            return otherGestureRecognizer as? UIPanGestureRecognizer != nil
        }
        return false
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 是否可以同时进行
        return gestureRecognizer == interactiveGestureRecognizer
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer != interactiveGestureRecognizer {
            return true
        }

        guard let navi = navigationController, let topViewController = navi.topViewController else {
            return false
        }

        if !checkDelegate() || // 代理无效
            isTransitioning || // 转场过程中
            navi.viewControllers.count <= 1 || // 不是非根视图
            !topViewController.isInteractivePopEnabled /* 不支持滑动手势 */ {
            return false
        }

        return topViewController.interactivePopGestureShouldReceive(touch: touch)
    }

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != interactiveGestureRecognizer {
            return true
        }

        guard
            let navi = navigationController,
            let topViewController = navi.topViewController,
            let translation = interactiveGestureRecognizer?.translation(in: navi.view) else {
                return true
        }
        return topViewController.interactivePopGestureShouldBegin(translation: translation)
    }

}

extension NavigationTransitioningDelegate: UINavigationControllerDelegate {

    public func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    public func navigationController(_ navigationController: UINavigationController,
                                     animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        var transitioning: BasicViewControllerAnimatedTransitioning?

        switch operation {
        case .push:
            transitioning = toVC.navigationControllerAnimatedTransitioning(forOperation: operation,
                                                                           interactive: interactiveTransition == nil)
            transitioning = transitioning ?? PushPopAnimatedTransitioning(type: .navigationPush)
        case .pop:
            transitioning = fromVC.navigationControllerAnimatedTransitioning(forOperation: operation,
                                                                             interactive: interactiveTransition == nil)
            transitioning = transitioning ?? PushPopAnimatedTransitioning(type: .navigationPop)
        case .none:
            return nil
        }

        transitioning?.delegate = self
        isTransitioning = transitioning != nil ? true : false
        return transitioning
    }
    
}

//----------------------------------------------------------
