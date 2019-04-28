//
//  BasicTransitioning
//

import UIKit

/// 模态推出页面，默认转场动画
final class PresentAnimatedTransitioning: BasicViewControllerAnimatedTransitioning {

    private(set) var type: PresentAnimatedType
    private var animations: (() -> Void)?

    override convenience init() {
        self.init(type: .present, animations: nil)
    }

    convenience init(type: PresentAnimatedType) {
        self.init(type: type, animations: nil)
    }

    init(type: PresentAnimatedType, animations: (() -> Void)?) {
        self.type = type
        self.animations = animations
        super.init()
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from) else {
                return
        }

        let toVCView = transitionContext.view(forKey: .to)
        let fromVCView = transitionContext.view(forKey: .from)

        // 容器视图
        let containerView = transitionContext.containerView
        // Frame
        let finalFrame    = transitionContext.finalFrame(for: toVC)

        if self.type == .present, let toV = toVCView {
            containerView.addSubview(toV)
            toV.frame = finalFrame.offsetBy(dx: 0, dy: finalFrame.height)
        }

        fromVC.beginAppearanceTransition(false, animated: true)
        toVC.beginAppearanceTransition(true, animated: true)

        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            if self.type == .present {
                if let toV = toVCView {
                    toV.frame = finalFrame
                }
            } else {
                let initialFrame = transitionContext.initialFrame(for: fromVC)
                if let fromV = fromVCView {
                    fromV.frame = CGRect(x: 0, y: containerView.frame.height, width: initialFrame.width, height: initialFrame.height)
                }
            }

            // 自定义动画
            self.animations?()
        }, completion: { finished in

            if transitionContext.transitionWasCancelled {
                fromVC.endAppearanceTransition()
                toVC.endAppearanceTransition()
            }
            // 通知完成
            self.didEndTransitioningAnimation(transitionContext: transitionContext, isFinished: finished)
        })
    }
    
}
