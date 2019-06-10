//
//  GameScene.swift
//  Project14
//

import SpriteKit

class GameScene: SKScene {
    
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    
    var popupTime = 0.85
    var numRounds = 0
    
    var hitFriendSound: SKAction!
    var hitEnemySound: SKAction!
    var gameOverSound1: SKAction!
    var gameOverSound2: SKAction!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x: 8, y: 8)
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }
        
        hitFriendSound = SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false)
        hitEnemySound = SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false)
        gameOverSound1 = SKAction.playSoundFileNamed("43698__notchfilter__game-over03.caf", waitForCompletion: true)
        gameOverSound2 = SKAction.playSoundFileNamed("72866__tim-kahn__game-over.caf", waitForCompletion: false)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            // new game button pressed
            if node.name == "newGame" {
                startNewGame()
                return
            }
            
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue }
            if !whackSlot.isVisible { continue }
            if whackSlot.isHit { continue }

            whackSlot.hit()
            
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                score -= 5
                
                run(hitFriendSound)
            }
            else if node.name == "charEnemy" {
                // they should have whacked this one
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
                
                score += 1
                
                run(hitEnemySound)
            }
        }
    }

    func startNewGame() {
        for child in children {
            if child.name == "gameOver" || child.name == "finalScore" || child.name == "newGame"{
                removeChildren(in: [child])
            }
        }
        
        popupTime = 0.85
        numRounds = 0
        score = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        }
    }
    
    func createSlot(at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }

    func createEnemy() {
        numRounds += 1
        
        if numRounds >= 30 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            gameOver.name = "gameOver"
            addChild(gameOver)
            
            // challenge 2
            let finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Final score: \(score)"
            finalScore.zPosition = 1
            finalScore.position = CGPoint(x: 512, y: 314)
            finalScore.horizontalAlignmentMode = .center
            finalScore.fontSize = 32
            finalScore.name = "finalScore"
            addChild(finalScore)

            // challenge 1
            let gameOverSoundSequence = SKAction.sequence([gameOverSound1, gameOverSound2])
            run(gameOverSoundSequence)

            // add new game label
            let newGame = SKLabelNode(fontNamed: "Verdana Bold")
            newGame.text = "> NEW GAME <"
            newGame.zPosition = 1
            newGame.position = CGPoint(x: 512, y: 264)
            newGame.horizontalAlignmentMode = .center
            newGame.fontSize = 24
            newGame.name = "newGame"
            addChild(newGame)

            return
        }
        
        popupTime *= 0.991
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)
        
        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        }
    }
}
