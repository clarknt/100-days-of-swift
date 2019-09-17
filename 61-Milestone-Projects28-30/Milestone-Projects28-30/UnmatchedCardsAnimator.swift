//
//  FlipAndUnmatchAnimator.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-09-16.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class UnmatchedCardsAnimator {

    // keyframes would be more convenient than chaining with completion handlers
    // but they don't play well with the flip animation, which is a transition

    private static let flipDuration = 0.3
    private static let waitDuration = 1.0

    private var flipToFrontAnimator: UIViewPropertyAnimator?
    private var waiter: DispatchWorkItem?
    private var flipToBackAnimator: UIViewPropertyAnimator?

    // launch animation
    func start(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    // cancel whole animation
    func cancel() {
        // TODO add synchronization lock
        waiter?.cancel()
        waiter = nil

        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        flipToBackAnimator?.stopAnimation(true)
        flipToBackAnimator = nil
    }

    // flip the cards back immediately
    func forceFlipToBack(oldCell: CardCell, newCell: CardCell) {
        cancel()
        flipToBack(oldCell: oldCell, newCell: newCell)
    }

    private func flipToFront(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFrontAnimator = UIViewPropertyAnimator(duration: UnmatchedCardsAnimator.flipDuration, timingParameters: UICubicTimingParameters())

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.wait(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func wait(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        waiter = DispatchWorkItem { [weak self] in
            self?.flipToBack(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.waiter = nil
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + UnmatchedCardsAnimator.waitDuration, execute: waiter!)
    }

    private func flipToBack(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToBackAnimator = UIViewPropertyAnimator(duration: UnmatchedCardsAnimator.flipDuration, timingParameters: UICubicTimingParameters())

        flipToBackAnimator?.addAnimations {
            oldCell.animateFlipTo(state: .back)
            newCell.animateFlipTo(state: .back)
        }

        flipToBackAnimator?.addCompletion { [weak self] position in
            self?.flipToBackAnimator = nil
            if position == .end {
                completion?()
            }
        }

        flipToBackAnimator?.startAnimation()
    }
}
