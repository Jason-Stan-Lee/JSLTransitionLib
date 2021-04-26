//
//  JSLTransitionLib
//

import UIKit

/// 半弹窗 PresentationController
@objc(JSLSemiPresentationController)
public class SemiPresentationController: UIPresentationController {

    /// 蒙层颜色，默认 黑色
    @objc public var dimmingColor = UIColor.black
    /// 设置蒙层 alpha 值，默认 0.5
    @objc public var dimmingAlpha: CGFloat = 0.5

    /// 是否允许点击蒙层退出页面, 默认 true
    @objc public var isEnableTapDismiss = true
    
    private var presentationWrappingView: UIView?
    private var dimmingView: UIView?
    private var cornerRadius: CGFloat = 16

    override public var presentedView: UIView? {
        return presentationWrappingView
    }

    /// presentation 转场开始
    override public func presentationTransitionWillBegin() {
        guard let presentedViewControllereView = super.presentedView else {
            return
        }

        presentationWrappingView = UIView(frame: frameOfPresentedViewInContainerView)

        let presentationRoundedCornerView = UIView(frame: (presentationWrappingView?.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: -cornerRadius, right: 0))) ?? CGRect.zero)
        presentationRoundedCornerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentationRoundedCornerView.layer.cornerRadius = cornerRadius
        presentationRoundedCornerView.layer.masksToBounds = true

        let presentedViewControllerWrapperView = UIView(frame: presentationRoundedCornerView.bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: cornerRadius, right: 0)))
        presentedViewControllerWrapperView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        presentedViewControllereView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        presentedViewControllereView.frame = presentedViewControllerWrapperView.bounds
        presentedViewControllerWrapperView.addSubview(presentedViewControllereView)

        presentationRoundedCornerView.addSubview(presentedViewControllerWrapperView)

        presentationWrappingView?.addSubview(presentationRoundedCornerView)

        //----------------------------------------------------------

        guard let container = containerView else {
            return
        }
        let dimView = UIView(frame: container.bounds)
        dimmingView = dimView
        dimmingView?.backgroundColor = dimmingColor
        dimmingView?.isOpaque = false
        dimmingView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:))))
        container.addSubview(dimView)

        let transitionCoordinator = presentingViewController.transitionCoordinator
        dimmingView?.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = self.dimmingAlpha
        }, completion: nil)
    }

    @objc
    private func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        if !isEnableTapDismiss {
            return
        }
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    /// presentation 转场结束
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        // 中途取消或者动画未完成等，completed 为 false
        if !completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }

    /// dismissal 转场开始
    override public func dismissalTransitionWillBegin() {

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }

    /// dismissal 转场结束
    override public func dismissalTransitionDidEnd(_ completed: Bool) {

        // 中途取消或者动画未完成等，completed 为 false
        if completed {
            presentationWrappingView = nil
            dimmingView = nil
        }
    }

}

// MARK: - Layout
extension SemiPresentationController {

    override public func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        if container.isEqual(presentedViewController) {
            containerView?.setNeedsLayout()
        }
    }

    override public func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        if container.isEqual(presentedViewController) {
            return container.preferredContentSize
        }
        return super.size(forChildContentContainer: container, withParentContainerSize: parentSize)
    }

    override public var frameOfPresentedViewInContainerView: CGRect {

        let containerViewBounds = containerView?.bounds ?? CGRect.zero
        let presentedViewContentSize = size(forChildContentContainer: presentedViewController, withParentContainerSize: containerViewBounds.size)

        var presentedViewControllerFrame = containerViewBounds
        presentedViewControllerFrame.size.height = presentedViewContentSize.height
        presentedViewControllerFrame.origin.y = containerViewBounds.maxY - presentedViewContentSize.height

        return presentedViewControllerFrame
    }

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()

        dimmingView?.frame = containerView?.bounds ?? CGRect.zero

        let containerViewFrame = frameOfPresentedViewInContainerView
        presentationWrappingView?.frame = containerViewFrame
    }

    public override var shouldRemovePresentersView: Bool {
        return true
    }

}

