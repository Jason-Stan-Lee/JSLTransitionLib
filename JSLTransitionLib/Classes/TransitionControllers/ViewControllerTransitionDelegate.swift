//
//  BasicTransitioning
//

import UIKit

/// presentation/dismiss 转场代理
@objc(JSLViewControllerTransitionDelegate)
public final class ViewControllerTransitionDelegate: NSObject {

    private var interactiveTransition: UIPercentDrivenInteractiveTransition?
    private var interactivePresentingViewController: UIViewController?
    private var interactiveGestureRecognizer: UIPanGestureRecognizer?
    private var currentInteractiveTransitionType: ModalTransitioningType = .none
    private var interactiveTransitionPercentComplete: CGFloat = 0

    private(set) weak var presentedViewController: UIViewController?
    /// 被当前视图控制器模态推出的视图控制器
    private(set) weak var presentToViewController: UIViewController?

    /// presentTo 方式转场过程中取消手势
    private var presentToDismissInterativeGestureRecognizer: UIPanGestureRecognizer?

    /// 是否正在交互 Dismiss
    private(set) var isInteractiveDismissing: Bool = false
    /// 是否正在交互 Presnet
    private(set) var isInteractivePresentTo: Bool = false
    /// 是否正在转场
    private(set) var isTransitioning: Bool = false

    // MARK: Life Cycle

    deinit {
        // 移除手势
        guard let interactiveGr = interactiveGestureRecognizer else {
            return
        }
        self.presentedViewController?.view.removeGestureRecognizer(interactiveGr)
    }

    @objc
    public init(presentedViewController: UIViewController) {
        self.presentedViewController = presentedViewController
        super.init()

        presentedViewController.modalPresentationStyle = .custom

        let interactiveGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleInteractiveGesture(_:)))
        interactiveGestureRecognizer.maximumNumberOfTouches = 1
        interactiveGestureRecognizer.delegate = self
        interactiveGestureRecognizer.isEnabled = false
        self.interactiveGestureRecognizer = interactiveGestureRecognizer
        // 添加手势
        presentedViewController.view.addGestureRecognizer(interactiveGestureRecognizer)
        // 设置转场代理
        presentedViewController.transitioningDelegate = self
    }

    // MARK: State Check

    private func checkDelegate() -> Bool {

        if presentedViewController?.transitioningDelegate === self {
            return true
        }
        // 代理已经更改失效, 清空 context

        interactiveGestureRecognizer?.removeTarget(self, action: #selector(handleInteractiveGesture(_:)))
        if let interactiveGr = interactiveGestureRecognizer {
            self.presentedViewController?.view.removeGestureRecognizer(interactiveGr)
            interactiveGestureRecognizer = nil
        }

        presentedViewController = nil
        interactivePresentingViewController = nil

        return false
    }

    // MARK: Actions

    @objc
    private func handlerPresentToVCInteraction(_ interactiveGr: UIPanGestureRecognizer) {
        // do nothing
    }

    @objc
    private func handleInteractiveGesture(_ interactiveGr: UIPanGestureRecognizer) {
        guard let presentedVC = presentedViewController else {
            return
        }

        switch interactiveGr.state {
        case .began:
            handleInteractiveGestureStateBegin(with: presentedVC)
        case .changed:
            handleInteractiveGestureStateChanged(interactiveGr, with: presentedVC)
            // 重置平移速度
            interactiveGr.setTranslation(CGPoint.zero, in: interactivePresentingViewController?.view)
        default:
            handleInteractiveGestureStateEnd(interactiveGr, with: presentedVC)
        }
    }
    
    /// 处理转场手势开始状态，初始化相关参数
    /// - Parameter presentedVC: 转场视图控制器
    private func handleInteractiveGestureStateBegin(with presentedVC: UIViewController) {

        // 初始化 InteractiveTransition
        interactiveTransition = UIPercentDrivenInteractiveTransition()
        interactiveTransition?.completionCurve = .linear
        interactiveTransitionPercentComplete = 0
        
        switch currentInteractiveTransitionType {
        case .dismiss:
            // 交互 Dismiss 时，给 presentingView 赋值
            interactivePresentingViewController = presentedVC.presentingViewController
            isInteractiveDismissing = true
            interactivePresentingViewController?.dismiss(animated: true, completion: nil)
        case .presentTo:
            // 允许交互推出新页面，同时提供了被推出页面视图控制器
            guard let presentToVC = presentedVC.viewControllerForInteractivePresentTo() else {
                resetInteractiveTransition()
                isTransitioning = false
                return
            }
            // 把当前页面（presenterdVC）赋值给 presentingView
            interactivePresentingViewController = presentedVC
            // 将设置被推出页面转场代理
            presentToVC.transitioningDelegate = self
            presentToVC.modalPresentationStyle = .custom
            presentToViewController = presentToVC
            isInteractivePresentTo = true
            
            // 添加转场过程中取消转场手势（为了在交互推出页面的转场过程中，下滑取消）
            let dismissGr = UIPanGestureRecognizer(target: self, action: #selector(handlerPresentToVCInteraction(_:)))
            dismissGr.delegate = self
            presentToVC.view.addGestureRecognizer(dismissGr)
            presentToDismissInterativeGestureRecognizer = dismissGr
            // 开始转场
            presentedVC.present(presentToVC, animated: true, completion: nil)
        default:
            // 非交互转场类型，重置
            resetInteractiveTransition()
            isTransitioning = false
            return
        }

        presentedVC.startInteractive(for: currentInteractiveTransitionType)
    }
    
    /// 转场手势移动状态处理
    /// - Parameter interactiveGr: 交互转场手势
    /// - Parameter presentedVC: 转场视图控制器
    private func handleInteractiveGestureStateChanged(_ interactiveGr: UIPanGestureRecognizer, with presentedVC: UIViewController) {

        // 手势变化时，确认 interactiveTransition 是否已经赋值
        guard let interactiveTransition = interactiveTransition else {
            return
        }
        let locationPoint = interactiveGr.location(in: interactivePresentingViewController?.view)
        let translation = interactiveGr.translation(in: interactivePresentingViewController?.view)

        // 完成比例
        var fraction = presentedVC.interactiveTransitionCompletePercent(for: currentInteractiveTransitionType,
                                                                        currentProcess: interactiveTransitionPercentComplete,
                                                                        location: locationPoint,
                                                                        translation: translation)
        fraction += interactiveTransitionPercentComplete
        interactiveTransitionPercentComplete = max(0, fraction)
        interactiveTransition.update(min(1, interactiveTransitionPercentComplete))
        
        // 是否需要中断交互转场
        let shouldInterrupt = presentedVC.interactiveTransitionShouldInterrupt(for: currentInteractiveTransitionType, currentProcess: interactiveTransitionPercentComplete)
        if shouldInterrupt {
            // 中断手势
            interactiveGr.isEnabled = false
            interactiveGr.isEnabled = true
        }
    }
    
    /// 结束交互手势处理
    /// - Parameter interactiveGr: 交互手势
    /// - Parameter presentedVC: 转场 VC
    /// - Parameter ignoreGrState: 是否需要忽略转场手势状态
    private func handleInteractiveGestureStateEnd(_ interactiveGr: UIPanGestureRecognizer,
                                                  with presentedVC: UIViewController) {
        
        // 手势结束或者取消时，确认 interactiveTransition 是否已经赋值
        guard let interactiveTransition = interactiveTransition else {
            return
        }
        
        let locationPoint = interactiveGr.location(in: interactivePresentingViewController?.view)
        let velocity = interactiveGr.velocity(in: interactivePresentingViewController?.view)
        
        // 手势结束，根据速度计算交互转场进度
        interactiveTransitionPercentComplete += presentedVC
            .interactiveTransitionCompletePercent(for: currentInteractiveTransitionType,
                                                  currentProcess: interactiveTransitionPercentComplete,
                                                  location: locationPoint,
                                                  translation: velocity)
        interactiveTransitionPercentComplete = min(interactiveTransitionPercentComplete, 1)
        interactiveTransitionPercentComplete = max(0, interactiveTransitionPercentComplete)
        
        if ((!interactiveGr.isEnabled || interactiveGr.state == .ended)
            && interactiveTransitionPercentComplete >= 0.4)
            || interactiveTransitionPercentComplete == 1 { // 完成
            interactiveTransition.finish()
            presentedVC.finishInteractive(for: currentInteractiveTransitionType)
        } else { // 取消
            interactiveTransition.cancel()
            presentedVC.cancelInteractive(for: currentInteractiveTransitionType)
        }

        resetInteractiveTransition()
    }
    
    /// 重置交互转场参数
    private func resetInteractiveTransition() {
        currentInteractiveTransitionType = .none
        if !isInteractivePresentTo {
            interactiveTransition = nil
        }

        interactivePresentingViewController = nil

        isInteractiveDismissing = false
        isInteractivePresentTo = false
    }

}

extension ViewControllerTransitionDelegate: UIGestureRecognizerDelegate {

    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == presentToDismissInterativeGestureRecognizer {
            if let presentTo = presentToViewController, let translation = presentToDismissInterativeGestureRecognizer?.translation(in: presentTo.view), translation.y > 0 {
                // 如果在交互推出新页面的过程中，下滑页面，则取消当前交互推出转场
                interactiveTransition?.cancel()
            }
            return false
        }

        if gestureRecognizer == interactiveGestureRecognizer, let presentedViewControler = self.presentedViewController {

            if let translation = interactiveGestureRecognizer?.translation(in: presentedViewController?.view),
                let location = interactiveGestureRecognizer?.location(in: presentedViewController?.view) {

                let type = presentedViewControler.interactiveTransitionType(for: location, translation: translation)
                if type == .dismiss {
                    currentInteractiveTransitionType = .dismiss
                } else if type == .presentTo, presentedViewControler.isInteractivePresentToEnable {
                    currentInteractiveTransitionType = .presentTo
                }

                return currentInteractiveTransitionType.supportInteractive()
            }
            return false
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if gestureRecognizer == interactiveGestureRecognizer, let presentedViewController = self.presentedViewController {
            if self.checkDelegate() && !isTransitioning && (presentedViewController.isInteractiveDismissEnable || presentedViewController.isInteractivePresentToEnable) {
                return presentedViewController.interactiveTransitionGestureShouldReceive(touch: touch)
            }
            return false
        }
        return true
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if gestureRecognizer == presentToDismissInterativeGestureRecognizer {
            return (otherGestureRecognizer as? UIPanGestureRecognizer != nil ||
                otherGestureRecognizer as? UISwipeGestureRecognizer != nil)
        }

        if gestureRecognizer != interactiveGestureRecognizer {
            return false
        }

        if let presentedVC = presentedViewController {
            return !presentedVC.interactiveGestureRecognizer(shouldRecognizeSimultaneouslyWith: otherGestureRecognizer)
        }

        return (otherGestureRecognizer as? UIPanGestureRecognizer != nil ||
            otherGestureRecognizer as? UISwipeGestureRecognizer != nil)
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (gestureRecognizer == interactiveGestureRecognizer)
    }

}

extension ViewControllerTransitionDelegate: BasicViewControllerAnimatedTransitioningDelegate {

    public func viewControllerAnimatedTransitioning(_ transitioning: BasicViewControllerAnimatedTransitioning, didEndTransitioning completed: Bool) {
        interactiveTransitionPercentComplete = 0
        isTransitioning = false
        interactiveGestureRecognizer?.isEnabled = true
        if let presentTo = presentToViewController {
            if completed {
                presentTo.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: presentTo)
                presentTo.presentationTransitioningDelegateS?.interactiveGestureRecognizer?.isEnabled = true
            }

            presentToViewController = nil
            presentTo.view.removeGestureRecognizer(presentToDismissInterativeGestureRecognizer!)
            presentToDismissInterativeGestureRecognizer = nil
            interactiveTransition = nil
        }
    }

}

extension ViewControllerTransitionDelegate: UIViewControllerTransitioningDelegate {

    public func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 获取转场动画
        let transitioning = presented.viewControllerAnimatedTransitioning(for: .presented) ?? PresentAnimatedTransitioning(type: .present)
        transitioning.delegate = self
        isTransitioning = true

        return transitioning
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // 获取转场动画
        let transitioning = dismissed.viewControllerAnimatedTransitioning(for: .dismiss) ?? PresentAnimatedTransitioning(type: .dismiss)
        transitioning.delegate = self
        isTransitioning = true

        return transitioning
    }

    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    public func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }

    public func presentationController(forPresented presented: UIViewController,
                                       presenting: UIViewController?,
                                       source: UIViewController) -> UIPresentationController? {
        return presented.presentationController(for: presented, presenting: presenting, source: source)
            ?? UIPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

