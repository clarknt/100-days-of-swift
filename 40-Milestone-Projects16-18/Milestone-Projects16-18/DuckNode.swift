//
//  DuckNode.swift
//  Milestone-Projects16-18
//

import SpriteKit

enum DuckType {
    case good
    case bad
}

class DuckNode: SKNode {

    static let ducks = ["brown", "white", "yellow"]
    var type: DuckType = .good
    var points = 100
    
    func configure(at position: CGPoint, type: DuckType, points: Int, xScale: CGFloat, yScale: CGFloat) {
        self.position = position
        self.type = type
        self.points = points
        
        let stick = SKSpriteNode(imageNamed: "stick_wood")
        stick.position = CGPoint(x: 0, y: 0)
        stick.zPosition = 0
        addChild(stick)
        
        let duckPrefix = "duck" + (type == .good ? "_target_" : "_")
        let duck = SKSpriteNode(imageNamed: duckPrefix + DuckNode.ducks.randomElement()!)
        duck.zPosition = 0.1
        duck.position = CGPoint(x: 0, y: 100)
        addChild(duck)

        self.xScale = xScale
        self.yScale = yScale
    }
}
