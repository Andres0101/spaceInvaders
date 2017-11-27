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
    var gameArea: CGRect
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    override init(size: CGSize) {
        let maxAspectRatio: CGFloat = 16.0/9.0
        let areaWidth = size.height / maxAspectRatio
        let margin = (size.width - areaWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: areaWidth, height: size.height)
        
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        
        startNewLevel()
    }
    
    func startNewLevel() {
        let create = SKAction.run(enemy)
        let waitToCreate = SKAction.wait(forDuration: 1)
        let createSequence = SKAction.sequence([create, waitToCreate])
        let createAlways = SKAction.repeatForever(createSequence)
        self.run(createAlways)
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
    
    func enemy() {
        let xStart = random(min: gameArea.minX, max: gameArea.maxX)
        let xEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: xStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: xEnd, y: -self.size.height * 0.2)
        
        //Creation
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        self.addChild(enemy)
        
        //Movement
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
        enemy.run(enemySequence)
        
        //Rotation
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
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
            
            //Création des limites pour que le joueur ne quitte pas le gameArea
            if  player.position.x > (gameArea.maxX - player.size.width/2) {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if  player.position.x < (gameArea.minX + player.size.width/2) {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
