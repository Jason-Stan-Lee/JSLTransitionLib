//
//  SemiPresentationController.swift
//  ZHModuleCreation
//
//  Created by JasonLee on 2019/1/22.
//

import UIKit

/// 半弹窗 PresentationController
public final class SemiPresentationController: UIPresentationController {

    private var presentationWrappingView: UIView? = nil
    private var dimmingView: UIView? = nil
    private var cornerRadius: CGFloat = 16
    private var topHandleView: UIView? = nil

    override public var presentedView: UIView? {
        return presentationWrappingView
    }

    /// presentation 转场开始
    override public func presentationTransitionWillBegin() {
        guard let presentedViewControllereView = super.presentedView else {
            return
        }

        topHandleView = UIView()
        topHandleView?.layer.cornerRadius = 3
        topHandleView?.clipsToBounds = true
        topHandleView?.backgroundColor = .white
        presentedViewControllereView.addSubview(topHandleView!)

        presentationWrappingView = UIView(frame: frameOfPresentedViewInContainerView)
        presentationWrappingView?.layer.shadowOpacity = 0.3
        presentationWrappingView?.layer.shadowRadius = 8.0
        presentationWrappingView?.layer.shadowOffset = CGSize(width: 0, height: -6)

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
        dimmingView = UIView(frame: container.bounds)
        dimmingView?.backgroundColor = UIColor.black
        dimmingView?.isOpaque = false
        dimmingView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        dimmingView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dimmingViewTapped(_:))))
        container.addSubview(dimmingView!)

        let transitionCoordinator = presentingViewController.transitionCoordinator
        dimmingView?.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.dimmingView?.alpha = 0.57
        }, completion: nil)
    }

    @objc
    func dimmingViewTapped(_ sender: UITapGestureRecognizer) {
        presentingViewController.dismiss(animated: true, completion: nil)
    }

    /// presentation 转场结束
    override public func presentationTransitionDidEnd(_ completed: Bool) {
        // 中途取消或者动画未完成等，completed 为 false
        if !completed {
            presentationWrappingView = nil
            dimmingView = nil
            topHandleView = nil
        }
    }

    /// dismissal 转场开始
    override public func dismissalTransitionWillBegin() {
        topHandleView?.backgroundColor = UIColor.gray

        let transitionCoordinator = presentingViewController.transitionCoordinator
        transitionCoordinator?.animate(alongsideTransition: { _ in
            self.topHandleView?.alpha = 0
            self.dimmingView?.alpha = 0
        }, completion: nil)
    }

    /// dismissal 转场结束
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        topHandleView?.backgroundColor = .lightGray

        // 中途取消或者动画未完成等，completed 为 false
        if completed {
            presentationWrappingView = nil
            dimmingView = nil
            topHandleView = nil
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

        let topHandleViewWidth: CGFloat = 40
        let topHandleViewFrame = CGRect(x: (containerViewFrame.width - topHandleViewWidth) * 0.5, y: 8, width: topHandleViewWidth, height: 4)
        topHandleView?.frame = topHandleViewFrame
    }

}

