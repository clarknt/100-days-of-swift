//
//  WhackSlot.swift
//  Project14
//

import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        // position relative to main scene
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        // default position of (0, 0) relative to slot
        addChild(sprite)
        
        let cropNode = SKCropNode()
        // position relative to slot
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        // position relative to cropNode
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode)
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        if isVisible { return }

        mudEffect(direction: .up)
        
        charNode.xScale = 1
        charNode.yScale = 1

        //charNode.run(SKAction.moveBy(x: 0, y: 80, duration: Double.random(in: 0.01...1)))
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
        isVisible = true
        isHit = false
        
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        }
        else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        }
    }
    
    func hide() {
        if !isVisible { return }
        
        mudEffect(direction: .down)
        
        //charNode.run(SKAction.moveBy(x: 0, y: -80, duration: Double.random(in: 0.01...1)))
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true

        // challenge 3
        smokeEffect()
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in
            self?.isVisible = false
        }
        
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
    
    // challenge 3
    func smokeEffect() {
        if let smoke = SKEmitterNode(fileNamed: "SmokeEmitter") {
            smoke.position = CGPoint(x: 0, y: 45)
            smoke.zPosition = 1
            smoke.numParticlesToEmit = 10
            smoke.particleLifetime = 0.75
            smoke.particleColor = SKColor.white
            smoke.particleAlpha = 0.2

            effectSequence(effect: smoke)
        }
    }
    
    enum Direction {
        case up
        case down
    }
    
    func mudEffect(direction: Direction) {
        if let mud = SKEmitterNode(fileNamed: "MudEmitter") {
            mud.position = CGPoint(x: 0, y: 0)
            mud.zPosition = 1
            mud.numParticlesToEmit = 100
            mud.particleBirthRate = 500
            mud.particleSize = CGSize(width: 30, height: 30)
            mud.particleColor = SKColor.brown
            mud.particleBlendMode = .replace
            switch direction {
            case .up:
                mud.particleLifetime = 0.30
                mud.particleSpeed = 1
                mud.particleSpeedRange = 300
            case .down:
                mud.particleLifetime = 0.10
                mud.particleSpeed = 100
                mud.particleSpeedRange = 0
            }
            
            effectSequence(effect: mud)
        }
    }

    func effectSequence(effect: SKEmitterNode) {
        // use a sequence to remove the node after the effect ends
        let action = SKAction.run { [weak self] in
            self?.addChild(effect)
        }
        let duration = SKAction.wait(forDuration: 2)
        let removal = SKAction.run { [weak self] in
            self?.removeChildren(in: [effect])
        }
        run(SKAction.sequence([action, duration, removal]))
    }
}
