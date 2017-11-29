//
//  GameScene.swift
//  Space Invaders
//
//  Created by etu on 27/11/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "player")
    let shootSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    let explisionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    var gameArea: CGRect
    
    //Creation des categories
    struct physicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1
        static let Bullet: UInt32 = 0b10 //2
        static let Enemy: UInt32 = 0b100 //4
    }
    
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
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        //Définir les propriétés du joueur (position, catégorie, collision, contact, etc ...)
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        self.addChild(player)
        
        startNewLevel()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //Créer des variables pour valider collision entre eux
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //Condition pour avoir toujours en body1 la catégorie la plus petite et en body2 la plus grande
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        //Conditions pour savoir quels objects ont pris contact
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Enemy {
            //Si le joueur a frappé l'ennemi
            showExplotion(position: body1.node!.position) //Montrer l'explosion dans la position du joueur
            showExplotion(position: body2.node!.position) //Montrer l'explosion dans la position de l'ennemi
            
            body1.node?.removeFromParent() //Effacer le joueur
            body2.node?.removeFromParent() //Effacer l'ennemi
        } else if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.Enemy {
            //Si la balle a frappé l'ennemi
            if  body2.node != nil {
                //Si l'ennemi est dans l'ecran
                if  body2.node!.position.y < self.size.height {
                    showExplotion(position: body2.node!.position) //Montrer l'explosion dans la position de l'ennemi
                } else {
                    return
                }
            }
            
            body1.node?.removeFromParent() //Effacer la balle
            body2.node?.removeFromParent() //Effacer l'ennemi
        }
    }
    
    //Fonction qui montre l'explosion
    func showExplotion(position: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = position
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explisionSound, scaleIn, fadeOut, remove])
        explosion.run(explosionSequence)
    }
    
    func startNewLevel() {
        let create = SKAction.run(enemy)
        let waitToCreate = SKAction.wait(forDuration: 1)
        let createSequence = SKAction.sequence([create, waitToCreate])
        let createAlways = SKAction.repeatForever(createSequence)
        self.run(createAlways)
    }
    
    func shoot() {
        //Créer une balle et définir ses propriétés (position, catégorie, collision, contact, etc ...)
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = physicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = physicsCategories.None
        bullet.physicsBody!.contactTestBitMask = physicsCategories.Enemy
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
        
        //Créer un ennemi et ses propiétés(position, catégorie, collision, contact, etc...)
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.None
        enemy.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
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
