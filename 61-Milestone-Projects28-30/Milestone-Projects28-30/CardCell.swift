//
//  CardCell.swift
//  Milestone-Projects28-30
//
//  Created by clarknt on 2019-07-23.
//  Copyright © 2019 clarknt. All rights reserved.
//

import UIKit

class CardCell: UICollectionViewCell {
    var front: UIImageView!
    var back: UIImageView!
    
    var card: Card?
    
    fileprivate let flipDuration = 0.3
    fileprivate let matchDuration = 2.0
    fileprivate let completeDuration = 2.0
    
    fileprivate var animateFlipToTask: DispatchWorkItem?
    fileprivate var animateMatchTask: DispatchWorkItem?
    fileprivate var animateCompleteGameTask: DispatchWorkItem?
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }
    
    func set(card: Card) {
        self.card = card
        front.image = UIImage(named: card.frontImage)
        back.image = UIImage(named: card.backImage)

        reset(state: card.state)
    }

    func animateFlipTo(state: CardState, delay: TimeInterval = 0) {
        guard state == .front || state == .back else { fatalError("Can only flip to front or back") }
        
        animateFlipToTask = DispatchWorkItem { [weak self] in
            let duration = self?.flipDuration ?? 0
            self?.animateFlipTo(state: state, duration: duration)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: animateFlipToTask!)
    }
    
    func animateMatch() {
        animateMatchTask = DispatchWorkItem {
            [weak self] in
            guard let matchDuration = self?.matchDuration else { return }

            UIView.animate(withDuration: matchDuration, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: {
                self?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            })
        }
        // wait for the flip completion, either from this card or the other card
        DispatchQueue.main.asyncAfter(deadline: .now() + flipDuration, execute: animateMatchTask!)
    }
    
    func animateCompleteGame(delay: TimeInterval = 0) {
        UIView.animate(withDuration: completeDuration, delay: delay, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    // use invalidateLayout() after rotation to force recomputing cell size
    override func layoutSubviews() {
        //super.layoutSubviews()
        resize()
    }
    
    // MARK:- Private functions
    
    fileprivate func build() {
        let size = frame.size
        
        front = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        front.contentMode = .scaleAspectFit
        front.isHidden = true
        
        back = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        back.contentMode = .scaleAspectFit
        
        addSubview(front)
        addSubview(back)
    }
    
    fileprivate func reset(state: CardState) {
        // cells are reused by the collection view, make sure to clean everything
        cancelAnimations()

        var flipTarget: CardState
        var scaleFactor: CGFloat
        
        // reset card position
        switch state {
        case .back:
            flipTarget = .back
            scaleFactor = 1
        case .front:
            flipTarget = .front
            scaleFactor = 1
        case .matched:
            flipTarget = .front
            scaleFactor = 0.6
        case .complete:
            flipTarget = .front
            scaleFactor = 1
        }

        animateFlipTo(state: flipTarget, duration: 0)
        DispatchQueue.main.async { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        }
    }
    
    fileprivate func resize() {
        let size = frame.size

        if !__CGSizeEqualToSize(front!.frame.size, size) {
            front.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        if !__CGSizeEqualToSize(back!.frame.size, frame.size) {
            back.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        }
        
        // reapply visible face and / or scaling
        if let card = card {
            reset(state: card.state)
        }
    }
    
    fileprivate func cancelAnimations() {
        layer.removeAllAnimations()
        front.layer.removeAllAnimations()
        back.layer.removeAllAnimations()
        
        // cancel timers that will trigger animations
        animateFlipToTask?.cancel()
        animateMatchTask?.cancel()
        animateCompleteGameTask?.cancel()
    }
    
    fileprivate func animateFlipTo(state: CardState, duration: Double, completionHandler: (() -> ())? = nil) {
        let from: UIView, to: UIView
        let transition: AnimationOptions
        
        if state == .front {
            guard getFacingSide() == .back else { return }
            from = back
            to = front
            transition = .transitionFlipFromRight
        }
        else {
            guard getFacingSide() == .front else { return }
            from = front
            to = back
            transition = .transitionFlipFromLeft
        }
        
        UIView.transition(from: from, to: to, duration: duration, options: [transition, .showHideTransitionViews])
    }
    
    fileprivate func getFacingSide() -> CardState {
        if back.isHidden {
            return .front
        }
        
        return .back
    }
}
