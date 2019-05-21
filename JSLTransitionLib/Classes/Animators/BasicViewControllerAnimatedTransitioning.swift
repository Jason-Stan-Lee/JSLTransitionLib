//
//  BasicViewControllerAnimatedTransitioning.swift
//
//  Created by JasonLee on 2019/4/23.
//

import UIKit

/// 视图控制器转场动画代理
public protocol BasicViewControllerAnimatedTransitioningDelegate: AnyObject {

    /// 转场动画结束
    ///
    /// - Parameters:
    ///   - viewControllerAnimatedTransitioning: 转场动画
    ///   - completed: 动画是否完成
    func viewControllerAnimatedTransitioning(_ transitioning: BasicViewControllerAnimatedTransitioning,
                                                            didEndTransitioning completed: Bool)
}

/// 视图控制器转场动画基类
open class BasicViewControllerAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {

    public enum PresentAnimatedType {
        case present, dismiss
    }

    open weak var delegate: BasicViewControllerAnimatedTransitioningDelegate?

    /// 转场时间
    open var transitionDuration: TimeInterval = 0.3

    /// 结束转场动画时调用
    /// NOTICE: 必须调用
    /// - Parameters:
    ///   - transitionContext: 转场上下文
    ///   - isFinished: CA 动画是否完成，不需要做其他逻辑判断
    open func didEndTransitioningAnimation(transitionContext: UIViewControllerContextTransitioning, isFinished: Bool) {
        let isCompleted = !transitionContext.transitionWasCancelled
        transitionContext.completeTransition(isCompleted)
        delegate?.viewControllerAnimatedTransitioning(self, didEndTransitioning: isCompleted)
    }

    // MARK: UIViewControllerAnimatedTransitioning

    open func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return (transitionContext?.isAnimated ?? false) ? transitionDuration : 0
    }

    open func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        didEndTransitioningAnimation(transitionContext: transitionContext, isFinished: true)
    }
    
}

