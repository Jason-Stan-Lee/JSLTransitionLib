//
//  BasicTransitioning
//

import UIKit

// MARK: AssociatedKeys
extension UIViewController {

    struct AssociatedKeys {
        static var presentationTransitioningDelegateS: UInt8 = 1
        static var navigationTransitioningDelegateS: UInt8 = 2
        static var isInteractiveDismissEnable: UInt8 = 3
        static var isInteractivePresentToEnable: UInt8 = 4
        static var isInteractivePopEnabled: UInt8 = 5
    }
    
}
