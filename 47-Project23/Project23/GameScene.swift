//
//  GameScene.swift
//  Project23
//

import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    
    var gameScore: SKLabelNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    
    // challenge 1
    let enemyPositionXRange = 64...960
    let enemyPositionY = -128
    let enemyAngularVelocityRange: ClosedRange<CGFloat> = -3...3
    let enemyVelocityYRange = 24...32
    let enemyVelocityX: [(CGFloat, ClosedRange<Int>)] = [
        (maxPosition: 256, range: 8...15),    // far left: move to the right
        (maxPosition: 512, range: 3...5),     // left: gently move to the right
        (maxPosition: 768, range: -5...(-3)), // right: gently move to the left
        (maxPosition: 961, range: -15...(-8)) // far right: move to the left
    ]
    let enemyVelocityMultiplier = 40
    
    // challenge 2
    let fastEnemyVelocityMultiplier = 50
    
    // bonus: new game option
    let enemyBodyRadius: CGFloat = 64
    
    // challenge 3
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6)
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        createSequence()
        
        // challenge 3
        gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.fontSize = 48
        gameOverLabel.text = "Game Over"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.zPosition = 1
        
        // bonus: new game option
        newGameLabel = SKLabelNode(fontNamed: "Chalkduster")
        newGameLabel.fontSize = 28
        newGameLabel.text = "> NEW GAME <"
        newGameLabel.position = CGPoint(x: 512, y: 324)
        newGameLabel.zPosition = 1
        newGameLabel.name = "NewGame"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func createSequence() {
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain]

        for _ in 0...1000 {
            sequence.append(.chain)
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
     
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0..<3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            
            // challenge 2
            if node.name == "fastenemy" {
                score += 4
            }

            // challenge 2
            if node.name == "enemy" || node.name == "fastenemy" {
                // destroy the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                }
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                // run simultaneously
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                node.run(seq)
                
                score += 1
                
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            }
            else if node.name == "bomb" {
                // destroy the bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue }
                
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                // run simultaneously
                let group = SKAction.group([scaleOut, fadeOut])
                
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)

                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }

    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true

        // stop everything from moving
        //physicsWorld.speed = 0 // let the nodes die instead
        //isUserInteractionEnabled = false // keep interaction enabled for new game button instead

        // prevent from launching new sequence
        nextSequenceQueued = true
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        addChild(gameOverLabel)
        addChild(newGameLabel)
        
        // cleanup - queue it to avoid interference with update method
        DispatchQueue.main.async { [weak self] in
            self?.cleanup()
        }
    }
    
    func cleanup() {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                node.removeAllActions()
                node.removeFromParent()
                activeEnemies.remove(at: index)
            }
        }
        bombSoundEffect?.stop()
        bombSoundEffect = nil
    }
    
    // bonus: new game option
    func newGame() {
        createSequence()
        sequencePosition = 0
        
        popupTime = 0.9
        chainDelay = 3.0
        score = 0
        physicsWorld.speed = 0.85

        lives = 3
        livesImages[0].texture = SKTexture(imageNamed: "sliceLife")
        livesImages[1].texture = SKTexture(imageNamed: "sliceLife")
        livesImages[2].texture = SKTexture(imageNamed: "sliceLife")

        gameOverLabel.removeFromParent()
        newGameLabel.removeFromParent()

        isGameEnded = false
        nextSequenceQueued = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"

        // wait for completion before calling the closure on "run"
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //guard isGameEnded == false else { return }

        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        // bonus: new game option
        if isGameEnded {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let nodesAtPoint = nodes(at: location)
            
            for node in nodesAtPoint {
                if node.name == "NewGame" {
                    newGame()
                }
            }
            
            return
        }
        
        // start fresh
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        // clear the slice shapes
        redrawActiveSlice()
        
        // remove unfinished fade out actions
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        // make slices visible (fadeOut has alpha going towards 0)
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
    }
    
    func redrawActiveSlice() {
        // not enough data to draw a line
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        
        // limit number of points
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1..<activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        // challenge 2
        // bomb wil be 0, penguin will be 1 to 6, fastpenguin will be 7
        var enemyType = Int.random(in: 0...7)
        
        if forceBomb == .never {
            enemyType = 1
        }
        else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            // on top of the penguins
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64)
                enemy.addChild(emitter)
            }
        }
        else if enemyType == 7 {
            // challenge 2
            enemy = SKSpriteNode(imageNamed: "fastpenguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "fastenemy"
        }
        else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        // challenge 1
        let randomPosition = CGPoint(x: Int.random(in: enemyPositionXRange), y: enemyPositionY)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: enemyAngularVelocityRange)
        var randomXVelocity: Int = 1
        
        for (maxPosition, range) in enemyVelocityX {
            if randomPosition.x < maxPosition {
                randomXVelocity = Int.random(in: range)
                break
            }
        }
        
        let randomYVelocity = Int.random(in: enemyVelocityYRange)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemyBodyRadius)
        // challenge 2
        let multiplier = enemyType == 7 ? fastEnemyVelocityMultiplier : enemyVelocityMultiplier
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * multiplier, dy: randomYVelocity * multiplier)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0

        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func substractLife() {
        lives -= 1
        
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        }
        else if lives == 1 {
            life = livesImages[1]
        }
        else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard isGameEnded == false else { return }
        
        if activeEnemies.count > 0 {
            // loop in reverse to be able to remove elements on the go
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" {
                        node.name = ""
                        substractLife()

                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                    // challenge 2
                    // fast enemies don't make the player lose lives
                    else if node.name == "bombContainer" || node.name == "fastenemy" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        }
        else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                
                nextSequenceQueued = true
            }
        }
        
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            // no bombs - stop the fuse sound
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        // progressively increase game difficulty
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()

        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()

        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4)) { [weak self] in
                self?.createEnemy()
            }
            
        case .fastChain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3)) { [weak self] in
                self?.createEnemy()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4)) { [weak self] in
                self?.createEnemy()
            }
        }
        
        sequencePosition += 1
        nextSequenceQueued = false
    }
}
