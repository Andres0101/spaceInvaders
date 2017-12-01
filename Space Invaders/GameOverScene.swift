//
//  GameOverScene.swift
//  Space Invaders
//
//  Created by etu on 01/12/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene {
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0
        self.addChild(background)
        
        //Label "Game Over"
        let gameOverText = SKLabelNode(fontNamed: "Roboto Black")
        gameOverText.text = "Game Over"
        gameOverText.fontSize = 200
        gameOverText.fontColor = SKColor.white
        gameOverText.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameOverText.zPosition = 1
        self.addChild(gameOverText)
        
        //Label "Score"
        let scoreText = SKLabelNode(fontNamed: "Roboto Medium")
        scoreText.text = "Score: \(score)"
        scoreText.fontSize = 90
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.55)
        scoreText.zPosition = 1
        self.addChild(scoreText)
        
        let defaults = UserDefaults()
        var highScore = defaults.integer(forKey: "highScoreSaved")
        
        if  score > highScore {
            highScore = score
            defaults.set(highScore, forKey: "highScoreSaved")
        }
        
        //Label "High score"
        let highScoreText = SKLabelNode(fontNamed: "Roboto Medium")
        highScoreText.text = "High score: \(highScore)"
        highScoreText.fontSize = 90
        highScoreText.fontColor = SKColor.white
        highScoreText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.45)
        highScoreText.zPosition = 1
        self.addChild(highScoreText)
        
        //Label "Restart"
        let restartText = SKLabelNode(fontNamed: "Roboto Regular")
        restartText.text = "Restart"
        restartText.fontSize = 100
        restartText.fontColor = SKColor.white
        restartText.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.3)
        restartText.zPosition = 1
        self.addChild(restartText)
    }
}
