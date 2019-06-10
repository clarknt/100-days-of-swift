//
//  GameScene.swift
//  Milestone-Projects16-18
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var waves = [WaveType: WaveNode]()
    var durations = [WaveType: TimeInterval]()
    var gameTimer: Timer?
    var timeTimer: Timer?
    var ducksCreated = 0
    var ducksRemoved = 0
    
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!

    var bullets: BulletsNode!
    
    var fireSound: SKAction!
    var emptyGunSound: SKAction!
    var reloadSound: SKAction!
    var alarmSound: SKAction!
    
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var timerLabel: SKLabelNode!
    var timer = 60 {
        didSet {
            timerLabel.text = "\(timer)s"
        }
    }
    
    override func didMove(to view: SKView) {
        generateBackground()

        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: 8, y: 720)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        
        timerLabel = SKLabelNode(fontNamed: "Chalkduster")
        timerLabel.text = "60s"
        timerLabel.position = CGPoint(x: 552, y: 720)
        timerLabel.horizontalAlignmentMode = .right
        timerLabel.fontSize = 48
        addChild(timerLabel)
        
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 68
        gameOverLabel.zPosition = 1
        
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.text = "> NEW GAME <"
        newGameLabel.position = CGPoint(x: 512, y: 324)
        newGameLabel.horizontalAlignmentMode = .center
        newGameLabel.name = "newGame"
        newGameLabel.fontSize = 38
        newGameLabel.zPosition = 1
        
        waves[.far] = addWave(at: CGPoint(x: -82, y: 350), zPosition: 0, xScale: 1, direction: .right)
        waves[.middle] = addWave(at: CGPoint(x: -82, y: 200), zPosition: 0.2, xScale: 0.75, direction: .left)
        waves[.close] = addWave(at: CGPoint(x: -82, y: 50), zPosition: 0.4, xScale: 0.5, direction: .right)

        bullets = BulletsNode()
        bullets.configure(at: CGPoint(x: 875, y: 735))
        bullets.name = "bullets"
        addChild(bullets)
        
        physicsWorld.gravity = .zero

        fireSound = SKAction.playSoundFileNamed("337697__thenikonproductions__gun-sound-4.caf", waitForCompletion: false)
        emptyGunSound = SKAction.playSoundFileNamed("387848__roll1n__to-aim-01.caf", waitForCompletion: false)
        reloadSound = SKAction.playSoundFileNamed("396331__nioczkus__1911-reload.caf", waitForCompletion: false)
        alarmSound = SKAction.playSoundFileNamed("198841__bone666138__analog-alarm-clock.caf", waitForCompletion: false)
        
        startGame()
    }

    func startGame() {
        durations[.far] = 4
        durations[.middle] = 5
        durations[.close] = 6
        score = 0
        timer = 60
        bullets.reload()
        gameOverLabel.removeFromParent()
        newGameLabel.removeFromParent()
        timeTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(decreaseTimer), userInfo: nil, repeats: true)
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(generateDucks), userInfo: nil, repeats: true)
    }
    
    func gameOver() {
        timeTimer?.invalidate()
        gameTimer?.invalidate()
        addChild(gameOverLabel)
        addChild(newGameLabel)
    }
    
    @objc func decreaseTimer() {
        timer -= 1

        if timer == 4 {
            run(alarmSound)
        }
        
        if timer <= 0 {
            gameOver()
        }
    }
    
    func generateBackground() {
        addBackground(x: 128, y: 384)
        addBackground(x: 384, y: 384)
        addBackground(x: 640, y: 384)
        addBackground(x: 896, y: 384)
        addBackground(x: 128, y: 640)
        addBackground(x: 384, y: 640)
        addBackground(x: 640, y: 640)
        addBackground(x: 896, y: 640)
    }
    
    func addBackground(x: CGFloat, y: CGFloat) {
        let background = SKSpriteNode(imageNamed: "bg_blue")
        background.position = CGPoint(x: x, y: y)
        background.zPosition = -1
        background.blendMode = .replace
        addChild(background)
    }

    func addWave(at position: CGPoint, zPosition: CGFloat, xScale: CGFloat, direction: WaveDirection) -> WaveNode {
        let wave = WaveNode()
        wave.configure(at: position, xScale: xScale, direction: direction)
        wave.zPosition = zPosition
        addChild(wave)
        wave.animate()
        return wave
    }
    
    @objc func generateDucks() {
        // 3/5 chances to generate a duck
        if Int.random(in: 1...5) <= 3 {
            addDuck(wave: waves[.close]!, scale: 1, duration: durations[.close]!, points: 100)
        }
        if Int.random(in: 1...5) <= 3 {
            addDuck(wave: waves[.middle]!, scale: 0.75, duration: durations[.middle]!, points: 200)

        }
        if Int.random(in: 1...5) <= 3 {
            addDuck(wave: waves[.far]!, scale: 0.5, duration: durations[.far]!, points: 300)
        }
        
        durations[.close]! *= 0.996
        durations[.middle]! *= 0.996
        durations[.far]! *= 0.996
    }
    
    func addDuck(wave: WaveNode, scale: CGFloat, duration: TimeInterval, points: Int) {
        let duck = DuckNode()
        let duckType: DuckType
        var actualPoints = points
        // 4/5 chances of a good duck
        if Int.random(in: 1...5) <= 4 {
            duckType = .good
        }
        else {
            duckType = .bad
            actualPoints = -1000
        }
        
        // as duck will be a child of wave, compensate for wave scale
        var xScale = scale * (1 / wave.xScale)
        let yScale = scale
        
        let startingPoint: CGFloat = wave.childrenStartingPoint
        let movement: CGFloat = wave.childrenMovement

        if wave.direction == .left {
            // reverse duck image
            xScale = -xScale
        }
        
        let position = CGPoint(x: startingPoint, y: 100)
        duck.configure(at: position, type: duckType, points: actualPoints, xScale: xScale, yScale: yScale)
        
        // put duck behind the wave it belongs to
        duck.zPosition = -0.1
        duck.name = "duck"
        wave.addChild(duck)

        // animate duck
        let moveAction = SKAction.move(by: CGVector(dx: movement, dy: 0), duration: duration)
        let removeAction = SKAction.customAction(withDuration: 1) { (duck, _) in
            duck.removeFromParent()
        }
        let sequence = SKAction.sequence([moveAction, removeAction])
        duck.run(sequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        var duckTapped = false
        
        for node in tappedNodes {
            if node.name == "newGame" {
                startGame()
                return
            }
            
            // game is on
            if timer > 0 {
                if node.name == "duck" {
                    duckTapped = true

                    // check bullets
                    if !bullets.remains() {
                        showReload()
                        return
                    }
                    bullets.decrease()
                    
                    // duck successfully tapped
                    if let duck = node as? DuckNode {
                        score += duck.points
                        showTappedScore(score: duck.points, position: location)
                    }

                    node.removeFromParent()

                     run(fireSound)
                    
                    // sometimes multiple ducks are tapped, count the first one only
                    break
                }
                
                // reload bullets tapped
                if node.name == "bullets" {
                    bullets.reload()
                    run(reloadSound)
                    return
                }
            }
        }
        
        // game is on and tapped elsewhere than on a duck
        if timer > 0 && !duckTapped {
            if !bullets.remains() {
                showReload()
                return
            }
            bullets.decrease()

            score -= 50
            showTappedScore(score: -50, position: location)
            
            run(fireSound)
        }
    }
    
    func showReload() {
        // create a new label each time to be able to stack them
        let reloadLabel = SKLabelNode(fontNamed: "Chalkduster")
        reloadLabel.text = "RELOAD"
        reloadLabel.position = CGPoint(x: 512, y: 384)
        reloadLabel.horizontalAlignmentMode = .center
        reloadLabel.fontSize = 80
        reloadLabel.fontColor = UIColor.red
        reloadLabel.zPosition = 1
        addChild(reloadLabel)

        // animate label
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let removeAction = SKAction.customAction(withDuration: 0) { (reloadLabel, _) in
            reloadLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([fadeOut, removeAction])
        reloadLabel.run(sequence)
        
        run(emptyGunSound)
    }
    
    func showTappedScore(score: Int, position: CGPoint) {
        // build text and color
        var scoreText = ""
        var textColor: UIColor!
        var outlineColor: UIColor!

        if score > 0 {
            scoreText += "+"
            textColor = UIColor(red: 0, green: 0.7, blue: 0, alpha: 1)
            outlineColor = UIColor.green
        }
        else {
            textColor = UIColor(red: 0.7, green: 0, blue: 0, alpha: 1)
            outlineColor = UIColor(red: 1, green: 0.45, blue: 0.45, alpha: 1)
        }
        scoreText += String(score)
        
        // build label
        let tmpScoreLabel = SKLabelNode()
        tmpScoreLabel.horizontalAlignmentMode = .center
        tmpScoreLabel.zPosition = 1
        tmpScoreLabel.position = position
        tmpScoreLabel.attributedText = getTappedScoreAttributes(for: scoreText, color: textColor, outline: outlineColor)
        addChild(tmpScoreLabel)

        // animate label
        let fadeAction = SKAction.fadeOut(withDuration: 1)
        let removeAction = SKAction.customAction(withDuration: 1) { (scoreLabel, _) in
            scoreLabel.removeFromParent()
        }
        let sequence = SKAction.sequence([fadeAction, removeAction])
        tmpScoreLabel.run(sequence)
    }
    
    func getTappedScoreAttributes(for text: String, color: UIColor, outline: UIColor) -> NSMutableAttributedString {
        let attStr: NSMutableAttributedString = NSMutableAttributedString(string: text)
        let scoreFont = UIFont(name: "Chalkduster", size: 38)
        attStr.addAttribute(.font, value: scoreFont as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.foregroundColor, value: color as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.strokeColor, value: outline as Any, range: NSMakeRange(0, attStr.length))
        attStr.addAttribute(.strokeWidth, value: -3.0, range: NSMakeRange(0, attStr.length))

        return attStr
    }
}
