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
    var container: UIView!

    fileprivate var hideAnimationComplete = true
    fileprivate var showAnimationComplete = true
    fileprivate var animationComplete: Bool {
        return hideAnimationComplete && showAnimationComplete
    }

    fileprivate var flipQueue = [CardSide]()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        buildCard()
    }
    
    func buildCard() {
        let size = frame.size
        container = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        front = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        front.contentMode = .scaleAspectFit
        front.backgroundColor = .white
        
        back = UIImageView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        back.contentMode = .scaleAspectFit
        back.backgroundColor = .white

        // put back view in front
        let backTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, 0.1)
        back.layer.transform = backTransform
        
        // and front view in back
        let frontTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 0, -0.1)
        front.layer.transform = frontTransform
        // flip view as it will be seen from behind
        front.transform = CGAffineTransform(scaleX: -1, y: 1)
        
        container.addSubview(back)
        container.addSubview(front)

        addSubview(container)
    }
    
    override func layoutSubviews() {
        resizeCard()
        super.layoutSubviews()
    }
    
    func resizeCard() {
        if !__CGSizeEqualToSize(container!.frame.size, frame.size) {
            container.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
        if !__CGSizeEqualToSize(front!.frame.size, frame.size) {
            front.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
        if !__CGSizeEqualToSize(back!.frame.size, frame.size) {
            back.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height)
        }
    }
    
    func set(frontImage: String, backImage: String) {
        front.image = UIImage(named: frontImage)
        back.image = UIImage(named: backImage)
    }
        
    func animateFound() {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
        })
    }
    
    func animateCompletion() {
        UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [], animations: { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    func flipTo(side: CardSide) {
        if animationComplete {
            triggerFlipAnimation(side: side)
        }
        else {
            flipQueue.append(side)
        }
    }
    
    fileprivate func triggerFlipAnimation(side: CardSide) {
        hideAnimationComplete = false
        showAnimationComplete = false

        let initialAngle = side == .front ? 0 : CGFloat.pi
        animateFlip(duration: 0.5, initialAngle: initialAngle) { [weak self] in
            self?.hideAnimationComplete = true
            self?.showAnimationComplete = true
        }
    }

    fileprivate func animateFlip(duration: Double, initialAngle: CGFloat = 0, completionHandler: (() -> ())?) {
        let fps: Double = 30
        
        // UIView animation is not working with sublayerTransform: animate manually
        DispatchQueue.global().async { [weak self] in
            let loops = Int(fps * duration)

            for i in 1...loops {
                usleep(useconds_t(1000000 / fps))
                
                var angle = initialAngle + CGFloat.pi * CGFloat(i) / CGFloat(loops)
                // make sure exact .pi is reached
                if i == loops {
                    angle = initialAngle + CGFloat.pi
                }
                
                var transform = CATransform3DIdentity
                transform.m34 = -1 / 500
                transform = CATransform3DRotate(transform, angle, 0, 1, 0)
                DispatchQueue.main.async {
                    self?.container.layer.sublayerTransform = transform
                }
            }
            
            completionHandler?()
        }
    }
    
    fileprivate func checkFlipQueue() {
        if animationComplete && !flipQueue.isEmpty {
            let side = flipQueue[0]
            flipQueue.remove(at: 0)
            triggerFlipAnimation(side: side)
        }
    }
}
