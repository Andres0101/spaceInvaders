//
//  MainMenuScene.swift
//  Space Invaders
//
//  Created by etu on 06/12/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene {
    
    override func didMove(to view: SKView) {
        //Background
        let backgroundEarth = SKSpriteNode(imageNamed: "backgroundEarth")
        backgroundEarth.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundEarth.zPosition = 0
        self.addChild(backgroundEarth)
        
        let backgroundStars = SKSpriteNode(imageNamed: "backgroundStars")
        backgroundStars.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundStars.zPosition = 0
        self.addChild(backgroundStars)
        
        //Label "Space Invaders"
        let gameName = SKLabelNode(fontNamed: "Roboto Black")
        gameName.text = "Space"
        gameName.fontSize = 200
        gameName.fontColor = SKColor.white
        gameName.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameName.zPosition = 1
        self.addChild(gameName)
        
        let gameName2 = SKLabelNode(fontNamed: "Roboto Black")
        gameName2.text = "Invaders"
        gameName2.fontSize = 200
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.625)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        //Label "Start game"
        let startGame = SKLabelNode(fontNamed: "Roboto Medium")
        startGame.name = "startButton"
        startGame.text = "Start Game"
        startGame.fontSize = 150
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        startGame.zPosition = 1
        self.addChild(startGame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let currentTouch = touch.location(in: self)
            let nodeITapped = atPoint(currentTouch)
            
            //Aller à gameScene
            if  nodeITapped.name == "startButton" {
                let changeTo = GameScene(size: self.size)
                changeTo.scaleMode = self.scaleMode
                let transition = SKTransition.fade(withDuration: 0.5)
                
                self.view!.presentScene(changeTo, transition: transition)
            }
        }
    }
}
