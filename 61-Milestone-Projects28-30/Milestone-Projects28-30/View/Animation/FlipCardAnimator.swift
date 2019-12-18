//
//  FlipCardAnimator.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-09-16.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class FlipCardAnimator {

    static let flipDuration = 0.3

    // store those to make current animation cancellable
    var flipAnimator: UIViewPropertyAnimator?

    func cancel() {
        flipAnimator?.stopAnimation(true)
        flipAnimator = nil
    }

    func flipTo(state: CardState, cell: CardCell) {
        flipAnimator = UIViewPropertyAnimator(duration: FlipCardAnimator.flipDuration, curve: .linear)

        flipAnimator?.addAnimations {
            cell.animateFlipTo(state: state)
        }

        flipAnimator?.addCompletion { [weak self] _ in
            self?.flipAnimator = nil
        }

        flipAnimator?.startAnimation()
    }
}
