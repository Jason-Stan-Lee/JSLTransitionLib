# JSLTransitionLib

[![CI Status](https://api.travis-ci.org/repos/Jason-Stan-Lee/JSLTransitionLib.svg?style=flat)](https://travis-ci.org/Jason-Stan-Lee/JSLTransitionLib)
[![Version](https://img.shields.io/cocoapods/v/JSLTransitionLib.svg?style=flat)](https://cocoapods.org/pods/JSLTransitionLib)
[![License](https://img.shields.io/cocoapods/l/JSLTransitionLib.svg?style=flat)](https://cocoapods.org/pods/JSLTransitionLib)
[![Platform](https://img.shields.io/cocoapods/p/JSLTransitionLib.svg?style=flat)](https://cocoapods.org/pods/JSLTransitionLib)


该库集成了转场手势管理、转场代理以及交互转场进度控制，使接入方更关注动画细节，不关心转场相关的基础开发。可以使不了解自定义转场内部细节的开发人员也能迅速上手

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

JSLTransitionLib is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'JSLTransitionLib'
```

## Author

jason_lee_92@yahoo.com

## License

JSLTransitionLib is available under the MIT license. See the LICENSE file for more info.

## 使用方式

#### 模态转场
支持交互 Dismiss 与 Present

- 设置视图控制器转场代理
```
// 设置单独视图控制器转场代理，不与其他视图控制器共用
let customTransitionVC = UIViewController()
customTransitionVC.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: customTransitionVC)

// 导航视图控制器，其子视图控制器共用同一转场代理，每个子视图控制器可以配置特有的转场动画，也可以由其父视图控制器统一配置其所有子视图的统一动画
let customTransitionNC = UINavigationController()
customTransitionNC.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: customTransitionNC)

// 工具栏控视图制器，其子视图控制器可以有自己独有的转场动画
let customTransitionTC = UITabBarController()
customTransitionTC.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: customTransitionTC)

```
- 配置自定义转场动画

```
// 在需要自定义转场动画的视图控制器中 override 该方法，根据不同转场类型，return 对应的动画，nil 则使用对应类型的默认动画
func viewControllerAnimatedTransitioning(for transitionType: TransitioningType) -> BasicViewControllerAnimatedTransitioning?

// 可以根据自定义转场动画的需要 return UIPresentationController 的子类, nil 为默认
func presentationController(for presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController?

// 返回在当前页面，「交互推出」的下一个视图控制器，nil 为不响应 presnetTo 手势事件
func viewControllerForInteractivePresentTo() -> UIViewController?

```
- 交互转场控制

```
/** 设置指定页面是否支持交互转场 **/
/// 是否允许交互 Dismiss
var isInteractiveDismissEnable: Bool { get set }
/// 是否允许交互 Present to 新页面
var isInteractivePresentToEnable: Bool { get set }

/** 设置转场手势的触发逻辑「手势触发的位置」、「手势触发的方向」 **/

/// 是否接收交互转场手势，返回 false 取消
func interactiveTransitionGestureShouldReceive(touch: UITouch) -> Bool

/// 根据手势滑动的位移、区分具体的转场类型，禁止转场返回 TransitioningType.none
func interactiveTransitionType(for location: CGPoint, translation: CGPoint) -> TransitioningType

/** 交互转场过程中的进度控制，location　和　translation 是每次触发手势事件的「阶段: fraction」位置和平移距离　**/
/// 位移和起始位置，返回进度
func interactiveTransitionCompletePercent(for transitionType: TransitioningType,
location: CGPoint,
translation: CGPoint) -> CGFloat

/// 与转场交互手势冲突时，是否可以同时进行，比如：上滑手势同时，页面的 scrollView 滚动等
func interactiveGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer, for transitionType: TransitioningType) -> Bool

```
- 交互转场过程

```

/// 是否正在 Dismiss 交互
var isInteractiveDismissing: Bool { get }
/// 是否正在交互 Present to 新页面
var isInteractivePresentTo: Bool { get }

/// 是否正在转场，包含交互转场和非交互转场
var isTransitioning: Bool { get }

/// 开始
func startInteractive(for transitionType: TransitioningType)
/// 完成
func finishInteractive(for transitionType: TransitioningType)
/// 取消
func cancelInteractive(for transitionType: TransitioningType)
```
#### 导航转场
目前只支持交互 Dismiss，暂不支持交互 Push

- 设置视图控制器转场代理
```
// 设置单独视图控制器转场代理，不与其他视图控制器共用
let customTransitionVC = UIViewController()
customTransitionVC.navigationTransitioningDelegate = NavigationTransitioningDelegate(navigationController: customTransitionVC)

// 导航视图控制器，其子视图控制器共用同一转场代理，每个子视图控制器可以配置特有的转场动画，也可以由其父视图控制器统一配置其所有子视图的统一动画
let customTransitionNC = UINavigationController()
customTransitionNC.navigationTransitioningDelegate = NavigationTransitioningDelegate(navigationController: customTransitionNC)

// 工具栏控视图制器，其子视图控制器可以有自己独有的转场动画
let customTransitionTC = UITabBarController()
customTransitionTC.navigationTransitioningDelegate = NavigationTransitioningDelegate(navigationController: customTransitionTC)

```
- 配置自定义转场动画

```
/// 根据 operation 转场动画, nil 为默认动画, 可重载返回定义转场动画
///
/// - Parameters:
///   - forOperation: 转场方式
///   - interactive: 是否为交互 pop
/// - Returns: 转场动画, nil 为默认
func navigationControllerAnimatedTransitioning(forOperation: UINavigationController.Operation, interactive: Bool) -> BasicViewControllerAnimatedTransitioning?

```
- 交互转场控制

```
/** 设置指定页面是否支持交互转场 **/
/// 是否允许交互 Dismiss
var isInteractivePopEnabled: Bool { get set }

/** 设置转场手势的触发逻辑「手势触发的位置」、「手势触发的方向」 **/

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
func navigationInteractivePopCompletePercent(forTranslation: CGPoint,
startPoint: CGPoint) -> CGFloat

```
- 交互转场过程

```

/// 是否正在交互 pop
var isInteractivePoping: Bool { get }

/// 是否正在过渡动画
var isNavigationTransitioning: Bool { get }

/// 开始
func startInteractivePop()
/// 完成
func finishInteractivePop()
/// 取消
func cancleInteractivePop()

```

