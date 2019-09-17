//
//  CompletionAnimator.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-09-16.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class CompletionAnimator {

    static let betweenCardsDelay = 0.05
    static let completeDuration = 2.0

    var animators = [UIViewPropertyAnimator]()
    var worker: DispatchWorkItem?

    // cancel whole animation
    func cancel() {
        worker?.cancel()

        for animator in animators {
            animator.stopAnimation(true)
        }
   }

    // launch animation
    func start(cards: [Card], collectionView: UICollectionView, completion: (() -> ())? = nil) {
        complete(cards: cards, collectionView: collectionView)
    }

    func complete(cards: [Card], collectionView: UICollectionView) {
        worker = DispatchWorkItem { [weak self] in
            var delay: TimeInterval = 0

            for i in 0..<cards.count {
                // worker.cancel() does not cancel current task, do it ourselves
                if (self?.worker?.isCancelled ?? false) { return }

                let indexPath = IndexPath(item: i, section: 0);
                guard let cell = collectionView.cellForItem(at: indexPath) as? CardCell else { continue }

                let springTiming = UISpringTimingParameters(dampingRatio: 0.3, initialVelocity: CGVector(dx: 5, dy: 5))
                let animator = UIViewPropertyAnimator(duration: MatchedCardsAnimator.matchDuration, timingParameters: springTiming)

                animator.addAnimations {
                    cell.animateCompleteGame()
                }

                animator.addCompletion { [weak self] _ in
                    self?.animators.removeAll(where: { $0 === animator })
                }

                self?.animators.append(animator)

                animator.startAnimation(afterDelay: delay)

                // 50ms to start animating each card with a delay
                delay += CompletionAnimator.betweenCardsDelay
            }
        }

        worker?.perform()
    }
}
