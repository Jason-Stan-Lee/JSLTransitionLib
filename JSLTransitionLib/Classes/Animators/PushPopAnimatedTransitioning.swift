//
//  JSLTransitionLib
//

import UIKit

struct PushPopAnimatedOption: OptionSet {
    let rawValue: Int

    static let left  = PushPopAnimatedOption(rawValue: 1 << 0)
    static let right = PushPopAnimatedOption(rawValue: 1 << 1)
    static let push  = PushPopAnimatedOption(rawValue: 1 << 2)
    static let pop   = PushPopAnimatedOption(rawValue: 1 << 3)

    static let leftPush: PushPopAnimatedOption  = [.left, .push]
    static let leftPop: PushPopAnimatedOption   = [.left, .pop]
    static let rightPush: PushPopAnimatedOption = [.right, .push]
    static let rightPop: PushPopAnimatedOption  = [.right, .pop]

    static let navigationPop: PushPopAnimatedOption = .rightPop
    static let navigationPush: PushPopAnimatedOption = .leftPush
}

/// Push Pop 类型转场动画
class PushPopAnimatedTransitioning: BasicViewControllerAnimatedTransitioning {

    private(set) var type: PushPopAnimatedOption = PushPopAnimatedOption.navigationPush
    private var animations: (() -> Void)?

    convenience init(type: PushPopAnimatedOption) {
        self.init(type: type, animations: nil)
    }

    init(type: PushPopAnimatedOption, animations: (() -> Void)?) {
        self.type = type
        self.animations = animations
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        // 容器视图
        let containerView = transitionContext.containerView
        // Frame
        let initialFrame  = transitionContext.initialFrame(for: fromVC)
        let finalFrame    = transitionContext.finalFrame(for: toVC)
        let viewWidth     = finalFrame.width

        if type.contains(.push) {
            toView.frame = finalFrame.offsetBy(dx: (type.contains(.left) ? viewWidth : -viewWidth), dy: 0)
            containerView.addSubview(toView)
        } else {
            toView.frame = finalFrame.offsetBy(dx: ((type.contains(.left) ? viewWidth : -viewWidth)) * 0.3, dy: 0)
            containerView.insertSubview(toView, belowSubview: fromView)
        }

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            toVC.view.frame = finalFrame
            if self.type.contains(.push) {
                fromView.frame = initialFrame.offsetBy(dx: (self.type.contains(.right) ? viewWidth : -viewWidth) * 0.3, dy: 0)
            } else {
                fromView.frame = initialFrame.offsetBy(dx: self.type.contains(.right) ? viewWidth : -viewWidth, dy: 0)
            }

            // 自定义操作
            self.animations?()
        }, completion: { finished in
            // 通知完成
            self.didEndTransitioningAnimation(transitionContext: transitionContext, isFinished: finished)
        })
    }
    
}
