//
//  FlipAndMatchAnimator.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-09-16.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class MatchedCardsAnimator {

    // keyframes would be more convenient than chaining with completion handlers
    // but they don't play well with the flip animation, which is a transition

    static let flipDuration = 0.3
    static let matchDuration = 2.0

    var flipToFrontAnimator: UIViewPropertyAnimator?
    var matchAnimator: UIViewPropertyAnimator?

    // cancel whole animation
    func cancel() {
        // could add a synchronization lock there
        flipToFrontAnimator?.stopAnimation(true)
        flipToFrontAnimator = nil

        matchAnimator?.stopAnimation(true)
        matchAnimator = nil
    }

    // launch animation
    func start(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFront(oldCell: oldCell, newCell: newCell, completion: completion)
    }

    private func flipToFront(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        flipToFrontAnimator = UIViewPropertyAnimator(duration: MatchedCardsAnimator.flipDuration, curve: .linear)

        flipToFrontAnimator?.addAnimations {
            newCell.animateFlipTo(state: .front)
        }

        flipToFrontAnimator?.addCompletion { [weak self] _ in
            self?.match(oldCell: oldCell, newCell: newCell, completion: completion)
            self?.flipToFrontAnimator = nil
        }

        flipToFrontAnimator?.startAnimation()
    }

    private func match(oldCell: CardCell, newCell: CardCell, completion: (() -> ())? = nil) {
        let springTiming = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: CGVector(dx: 5, dy: 5))
        matchAnimator = UIViewPropertyAnimator(duration: MatchedCardsAnimator.matchDuration, timingParameters: springTiming)

        matchAnimator?.addAnimations {
            oldCell.animateMatch()
            newCell.animateMatch()
        }

        matchAnimator?.addCompletion { [weak self] _ in
            self?.matchAnimator = nil
            completion?()
        }

        matchAnimator?.startAnimation()
    }
}
