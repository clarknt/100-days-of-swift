//
//  WaveNode.swift
//  Milestone-Projects16-18
//

import SpriteKit

enum WaveType {
    case close
    case middle
    case far
}

enum WaveDirection {
    case right
    case left
}

class WaveNode: SKNode {
    let waves = "Water"
    var direction: WaveDirection = .right
    var childrenStartingPoint: CGFloat = -200
    var childrenMovement: CGFloat = 1400
    
    func configure(at position: CGPoint, xScale: CGFloat, direction: WaveDirection) {
        self.position = position
        self.direction = direction
        childrenMovement = childrenMovement / xScale
        
        if direction == .left {
            childrenStartingPoint += childrenMovement
            childrenMovement = -childrenMovement
        }

        let nWave = Int(1 / xScale) + 1
        for i in 0...nWave {
            // stick several waves together to have them taller without stretching them
            addWave(x: 66 + (i * 798), y: -100)
            addWave(x: 66 + (i * 798), y: -50)
            addWave(x: 66 + (i * 798), y: 0)
            addWave(x: 66 + (i * 798), y: 50)
        }
        
        self.xScale = xScale
        self.yScale = 1
        
        self.isUserInteractionEnabled = false
    }
    
    func addWave(x: Int, y: Int) {
        let wave = SKSpriteNode(imageNamed: waves)
        wave.position = CGPoint(x: x, y: y)
        addChild(wave)
    }
    
    func animate() {
        let rotateCW = SKAction.rotate(byAngle: CGFloat.pi / 128, duration: getDuration())
        let rotateCCW = SKAction.rotate(byAngle: CGFloat.pi / -128, duration: getDuration())
        let goDown = SKAction.moveBy(x: 0, y: -20, duration: getDuration())
        let goUp = SKAction.moveBy(x: 0, y: 20, duration: getDuration())
        let goLeft = SKAction.moveBy(x: -20, y: 0, duration: getDuration())
        let goRight = SKAction.moveBy(x: 20, y: 0, duration: getDuration())
        
        let sequence1 = SKAction.sequence([rotateCW, goDown, goLeft, rotateCCW, goUp, rotateCCW, goDown, goRight, rotateCW, goUp])
        let sequence2 = SKAction.sequence([rotateCCW, goUp, goRight, rotateCW, goDown, rotateCW, goUp, goLeft, rotateCCW, goDown])
        let forever = SKAction.repeatForever([sequence1, sequence2].randomElement()!)
        self.run(forever)
    }
    
    func getDuration() -> Double {
        return Double.random(in: 0.2...0.6)
    }
}
