//
//  GameOverScene.swift
//  Space Invaders
//
//  Created by etu on 01/12/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import Foundation
import SpriteKit
import Firebase

class GameOverScene: SKScene {
    
    var databaseRef: DatabaseReference!
    let restartText = SKLabelNode(fontNamed: "Roboto Medium")
    var userID: String!
    var userHighScore: Int!
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        //Label "Game Over"
        let gameOverText = SKLabelNode(fontNamed: "Roboto Black")
        gameOverText.text = "Game Over"
        gameOverText.fontSize = 110
        gameOverText.fontColor = SKColor.white
        gameOverText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.8)
        gameOverText.zPosition = 1
        self.addChild(gameOverText)
        
        //Label "Score"
        let scoreText = SKLabelNode(fontNamed: "Roboto Regular")
        scoreText.text = "Score: \(score)"
        scoreText.fontSize = 70
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 100)
        scoreText.zPosition = 1
        self.addChild(scoreText)
        
        // Si le score est plus grand que le hightScore que l'utilisateur avait ...
        if  score > userHighScore {
            userHighScore = score
            
            // On met à jour le nouveau hightScore dans la BDD
            databaseRef = Database.database().reference()
            let ref = databaseRef.child("user").child(userID)
            ref.updateChildValues(["score": score])
        }
        
        //Label "High score"
        let highScoreText = SKLabelNode(fontNamed: "Roboto Regular")
        highScoreText.text = "High score: " + String(userHighScore)
        highScoreText.fontSize = 70
        highScoreText.fontColor = SKColor.white
        highScoreText.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        highScoreText.zPosition = 1
        self.addChild(highScoreText)
        
        //Label "Restart"
        restartText.text = "Restart"
        restartText.fontSize = 90
        restartText.fontColor = SKColor.white
        restartText.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        restartText.zPosition = 1
        self.addChild(restartText)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let currentTouch = touch.location(in: self)
            
            //Retour à gameScene
            if  restartText.contains(currentTouch) {
                let changeTo = GameScene(size: self.size)
                changeTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                
                self.view!.presentScene(changeTo, transition: transition)
            }
        }
    }
}
