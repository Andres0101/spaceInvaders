//
//  GameScene.swift
//  Space Invaders
//
//  Created by etu on 27/11/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    let player = SKSpriteNode(imageNamed: "player")
    let shootSound = SKAction.playSoundFileNamed("shoot.mp3", waitForCompletion: false)
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        self.addChild(player)
    }
    
    func shoot() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([shootSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        shoot()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let currentTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            
            let amountDragged = currentTouch.x - previousTouch.x
            
            player.position.x += amountDragged
        }
    }
}
