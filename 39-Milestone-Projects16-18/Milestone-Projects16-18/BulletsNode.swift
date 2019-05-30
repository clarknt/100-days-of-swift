//
//  BulletsNode.swift
//  Milestone-Projects16-18
//

import SpriteKit

class BulletsNode: SKNode {

    var bullets = [SKSpriteNode]()
    var bulletsCount = 6
    let loadedTexture = SKTexture(imageNamed: "icon_bullet_gold_long")
    let emptyTexture = SKTexture(imageNamed: "icon_bullet_empty_long")
    
    func configure(at position: CGPoint) {
        self.position = position
    
        bullets.append(addBullet(x: 0))
        bullets.append(addBullet(x: 25))
        bullets.append(addBullet(x: 50))
        bullets.append(addBullet(x: 75))
        bullets.append(addBullet(x: 100))
        bullets.append(addBullet(x: 125))
        
        // enlarge bullet tap area
        let transparency = SKSpriteNode()
        transparency.size = CGSize(width: 200, height: 150)
        transparency.position = CGPoint(x: -100, y: -75)
        addChild(transparency)
    }
    
    func addBullet(x: Int) -> SKSpriteNode {
        let bullet = SKSpriteNode(imageNamed: "icon_bullet_gold_long")
        bullet.zPosition = 1
        bullet.position = CGPoint(x: x, y: 0)
        addChild(bullet)
        return bullet
    }
    
    // return false if no bullet available
    func decrease() {
        if bulletsCount <= 0 {
            return
        }
        
        bulletsCount -= 1
        bullets[bulletsCount].texture = emptyTexture
    }

    func remains() -> Bool {
        return bulletsCount > 0
    }
    
    func reload() {
        for bullet in bullets {
            bullet.texture = loadedTexture
        }
        bulletsCount = 6
    }
}
