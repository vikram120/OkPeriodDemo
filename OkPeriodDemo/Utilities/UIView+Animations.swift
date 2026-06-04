//
//  UIView+Animations.swift
//  OkPeriodDemo
//
//  Created by Vikram Kunwar on 04/06/26.
//

import UIKit

extension UIView {
    func fadeIn(duration: TimeInterval = 0.45, delay: TimeInterval = 0, completion: (() -> Void)? = nil) {
        alpha = 0
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: [.curveEaseOut],
            animations: { self.alpha = 1 },
            completion: { _ in completion?() }
        )
    }

    func applyTapScaleEffect() {
        let animator = UIViewPropertyAnimator(duration: 0.12, dampingRatio: 0.6) {
            self.transform = CGAffineTransform(scaleX: 0.96, y: 0.96)
        }
        animator.addCompletion { _ in
            UIView.animate(withDuration: 0.12) {
                self.transform = .identity
            }
        }
        animator.startAnimation()
    }
}

extension UINavigationController {
    static func makeSmoothTransition() -> CATransition {
        let transition = CATransition()
        transition.duration = 0.35
        transition.type = .push
        transition.subtype = .fromRight
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return transition
    }
}
