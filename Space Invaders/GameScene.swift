//
//  GameScene.swift
//  Space Invaders
//
//  Created by etu on 27/11/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import SpriteKit
import GameplayKit

var score = 0
var userScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Variable pour accéder aux variables dans GameViewController
    var referenceOfGameViewController: GameViewController!
    var userID: String!
    
    // Variables globales
    var level = 0
    
    let scoreText = SKLabelNode(fontNamed: "Roboto Regular")
    
    var lives = 3
    let livesText = SKLabelNode(fontNamed: "Roboto Regular")
    
    let userNameLabel = SKLabelNode(fontNamed: "Roboto Regular")
    let highScoreLabel = SKLabelNode(fontNamed: "Roboto Regular")
    let startLabel = SKLabelNode(fontNamed: "Roboto Medium")

    let player = SKSpriteNode(imageNamed: "player")
    let shootSound = SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)
    let explisionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    var gameArea: CGRect
    
    // États de jeu
    enum gameState {
        case beforeGame
        case duringGame
        case afterGame
    }
    
    // Le jeu commence dans la scène de login
    var currentGameState = gameState.beforeGame
    
    //================================= Creation des categories =================================
    // Faciliter la différenciation des éléments utilisés dans le jeu
    struct physicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 // 1
        static let Bullet: UInt32 = 0b10 // 2
        static let Enemy: UInt32 = 0b100 // 4
    }
    
    //================= Fonction pour la position de départ random de l'ennemi ==================
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    //============================= Fonction qui crée le game area ==============================
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
    
    //===================================== Fonction initial ====================================
    override func didMove(to view: SKView) {
        userID = referenceOfGameViewController.userId // ID du joueur actuel dans le jeu
        
        self.physicsWorld.contactDelegate = self
        score = 0
        
        // Image de fond du jeu
        let backgroundEarth = SKSpriteNode(imageNamed: "backgroundEarth")
        backgroundEarth.size = self.size
        backgroundEarth.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        backgroundEarth.zPosition = 0
        self.addChild(backgroundEarth)
        
        // Effet du movement du background
        for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "backgroundStars")
            background.name = "Background"
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5, y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            background.zPosition = 1
            self.addChild(background)
        }
        
        // Définir les propriétés du joueur (position, catégorie, collision, contact, etc ...)
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - self.size.height)
        player.zPosition = 3
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        self.addChild(player)
        
        // Définir les propiétés du text "Score" (font family, size, position, etc...)
        scoreText.text = "Score: 0"
        scoreText.fontSize = 55
        scoreText.fontColor = SKColor.white
        scoreText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreText.position = CGPoint(x: self.size.width * 0.20, y: self.size.height + scoreText.frame.size.height)
        scoreText.zPosition = 20
        scoreText.alpha = 0.5
        self.addChild(scoreText)
        
        // Définir les propiétés du text "Life" (font family, size, position, etc...)
        livesText.text = "Lives: 3"
        livesText.fontSize = 55
        livesText.fontColor = SKColor.white
        livesText.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesText.position = CGPoint(x: self.size.width * 0.80, y: self.size.height + livesText.frame.size.height)
        livesText.zPosition = 20
        livesText.alpha = 0.5
        self.addChild(livesText)
        
        // Déplacement du score label & life label
        let moveToScreen = SKAction.moveTo(y: self.size.height * 0.9, duration: 0.3)
        scoreText.run(moveToScreen)
        livesText.run(moveToScreen)
        
        // Données du joueur
        if let currentUser = GIDSignIn.sharedInstance().currentUser {
            //Image
            let avatar = currentUser.profile.imageURL(withDimension: 300)
            let theImage = UIImage(data: NSData(contentsOf: avatar!)! as Data)
            let texture = SKTexture(image: theImage!)
            let mySprite = SKSpriteNode(texture: texture)
            mySprite.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 400)
            mySprite.zPosition = 3
            mySprite.name = "Avatar"
            self.addChild(mySprite)
            
            //Prenom
            userNameLabel.text = currentUser.profile.name
            userNameLabel.fontSize = 60
            userNameLabel.fontColor = SKColor.white
            userNameLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 150)
            userNameLabel.zPosition = 3
            self.addChild(userNameLabel)
        }
        
        // Chercher dans la BDD le High score du joueur
        referenceOfGameViewController.databaseRef.child("user").child(userID).observeSingleEvent(of: .value, with: { (snapshot) in
            // Obtenir le score du joueur de la BDD
            let value = snapshot.value as? NSDictionary
            let highScore = value?["score"] as? Int ?? 0
            userScore = highScore
            
            self.highScoreLabel.text = "High score: \(userScore)" // Ajouter la valeur du score dans un label
        }) { (error) in
            print(error.localizedDescription)
        }
        
        // Label High Score
        highScoreLabel.fontSize = 60
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 50)
        highScoreLabel.zPosition = 3
        self.addChild(highScoreLabel)
        
        // Définir les propiétés du text "Tap to begin" (font family, size, position, etc...)
        startLabel.text = "TAP TO BEGIN"
        startLabel.fontSize = 70
        startLabel.fontColor = SKColor.white
        startLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/4)
        startLabel.zPosition = 3
        startLabel.alpha = 0
        self.addChild(startLabel)
        
        // FadeIn transition
        let fadeInStartLabel = SKAction.fadeIn(withDuration: 0.3)
        startLabel.run(fadeInStartLabel)
    }
    
    //=============================== Fonction qui démarre le jeu ===============================
    func startGame() {
        currentGameState = gameState.duringGame // Changer etats du jeu à "Play"
        
        // FadeIn transition pour "Score" & "Lives"
        let fadeInScore = SKAction.fadeIn(withDuration: 0.3)
        scoreText.run(fadeInScore)
        livesText.run(fadeInScore)
        
        // Supprimer les labels "Tap to begin", prenom et score du joueur
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOut, delete])
        startLabel.run(deleteSequence)
        userNameLabel.run(deleteSequence)
        highScoreLabel.run(deleteSequence)
        
        // Obtenir avatar
        self.enumerateChildNodes(withName: "Avatar") {
            avatar, stop in
            avatar.run(deleteSequence) // Supprimer avatar du joueur
        }
        
        // Animation pour le joueur
        let moveShip = SKAction.moveTo(y: self.size.height * 0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShip, startLevelAction])
        player.run(startGameSequence)
    }
    
    //====================== Fonction qui augmente la difficulté du niveau ======================
    func startNewLevel() {
        var levelTime = TimeInterval()
        level += 1
        
        if  self.action(forKey: "createEnemy") != nil {
            self.removeAction(forKey: "createEnemy")
        }
        
        // Niveaux du jeu
        // Après chaque levelTime spécifié dans le case, le niveau du jeu change
        switch level {
            case 1:
                levelTime = 1.2
            case 2:
                levelTime = 1
            case 3:
                levelTime = 0.8
            case 4:
                levelTime = 0.4
            default:
                levelTime = 0.4
        }
        
        let create = SKAction.run(enemy) // Créer l'ennemi
        let waitToCreate = SKAction.wait(forDuration: levelTime) // Temps d'attente entre la création de chaque ennemi
        let createSequence = SKAction.sequence([waitToCreate, create])
        let createAlways = SKAction.repeatForever(createSequence) // Boucle de la création de l'ennemi
        self.run(createAlways, withKey: "createEnemy")
    }
    
    //=============================== Fonction qui diminue la vie ===============================
    func loseLife() {
        lives -= 1
        livesText.text = "Lives: \(lives)"
        
        // Petite animation visuelle pendant la diminution de la vie
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSquence = SKAction.sequence([scaleUp, scaleDown])
        livesText.run(scaleSquence)
        
        // Si lives est égale à 0, le jeu se termine
        if  lives == 0 {
            gameOver()
        }
    }
    
    //============================== Fonction qui augmente le score =============================
    func addScore() {
        score += 1
        scoreText.text = "Score: \(score)"
        
        // Si le score est égale à 10, 25 ou 50, le niveau du jeu augmente
        if  score == 10 || score == 25 || score == 50 {
            startNewLevel()
        }
    }
    
    //==================================== Fonction GameOver ====================================
    func gameOver() {
        currentGameState = gameState.afterGame
        self.removeAllActions()
        
        // Obtenir bullet de sa fonction et le supprimer
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            bullet.removeAllActions()
        }
        
        // Obtenir enemy de sa fonction et le supprimer
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        
        // Appeler la méthode changeScene()
        let changeSceneAction = SKAction.run(changeScene)
        let waitChangeScene = SKAction.wait(forDuration: 0.5)
        let changeSceneSequence = SKAction.sequence([waitChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    //=============================== Fonction qui change la scènce =============================
    func changeScene() {
        let newScene = GameOverScene(size: self.size) // Définir la scène
        newScene.scaleMode = self.scaleMode
        
        // Envoyer highScore du joueur à GameOverScene
        newScene.userHighScore = userScore
        newScene.userID = userID
        
        let transition = SKTransition.fade(withDuration: 0.5)
        
        self.view!.presentScene(newScene, transition: transition) // Changer la scène
    }
    
    //=================== Fonction qui valide la collision entre les éléments ===================
    func didBegin(_ contact: SKPhysicsContact) {
        // Créer des variables pour valider collision entre eux
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        // Condition pour avoir toujours en body1 la catégorie la plus petite et en body2 la plus grande
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            body1 = contact.bodyA
            body2 = contact.bodyB
        } else {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // Conditions pour savoir quels objects ont pris contact
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Enemy {
            // Si le joueur a frappé l'ennemi
            showExplotion(position: body1.node!.position) // Montrer l'explosion dans la position du joueur
            showExplotion(position: body2.node!.position) // Montrer l'explosion dans la position de l'ennemi
            
            body1.node?.removeFromParent() // Effacer le joueur
            body2.node?.removeFromParent() // Effacer l'ennemi
            
            gameOver()
        } else if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.Enemy { // Si la balle a frappé l'ennemi
            if  body2.node != nil {
                // Si l'ennemi est dans l'ecran
                if  body2.node!.position.y < self.size.height {
                    showExplotion(position: body2.node!.position) // Montrer l'explosion dans la position de l'ennemi
                    addScore() // Augmenter le score
                } else {
                    return
                }
            }
            
            body1.node?.removeFromParent() // Effacer la balle
            body2.node?.removeFromParent() // Effacer l'ennemi
        }
    }
    
    //============================= Fonction qui montre l'explosion =============================
    func showExplotion(position: CGPoint) {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = position
        explosion.zPosition = 4
        explosion.setScale(0)
        self.addChild(explosion)
        
        // Animation scaleIn et FadeOut
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([explisionSound, scaleIn, fadeOut, remove])
        explosion.run(explosionSequence)
    }
    
    //============================== Fonction qui montre la balle ===============================
    func shoot() {
        // Créer une balle et définir ses propriétés (position, catégorie, collision, contact, etc ...)
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 2
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
    
    //============================== Fonction qui montre l'ennemie ==============================
    func enemy() {
        let xStart = random(min: gameArea.minX, max: gameArea.maxX)
        let xEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: xStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: xEnd, y: -self.size.height * 0.2)
        
        // Créer un ennemi et ses propiétés(position, catégorie, collision, contact, etc...)
        let enemy = SKSpriteNode(imageNamed: "enemy")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 3
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.None
        enemy.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        self.addChild(enemy)
        
        // Movement & si l'ennemie quitte l'écran, le joueur perd une vie
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseLifeAction = SKAction.run(loseLife) // Joueur perd une vie
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseLifeAction])
        
        if  currentGameState == gameState.duringGame {
            enemy.run(enemySequence)
        }
        
        // Rotation
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // On ne peut jouer que si le jeu est dans l'écran d'accueil
        if  currentGameState == gameState.beforeGame {
            startGame()
        } else if  currentGameState == gameState.duringGame { // On n'utilise les balles que si le jeu est "active"
            shoot()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let currentTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            
            let amountDragged = currentTouch.x - previousTouch.x
            
            // Le joueur ne peut se déplacer que si le jeu est "active"
            if  currentGameState == gameState.duringGame {
                player.position.x += amountDragged
            }
            
            // Création des limites pour que le joueur ne quitte pas le gameArea
            if  player.position.x > (gameArea.maxX - player.size.width/2) {
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if  player.position.x < (gameArea.minX + player.size.width/2) {
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
    
    //======= Fonction qui permet de déplacer le background verticalement chaque seconde ========
    var lastUpdateTime: TimeInterval = 0
    var detlaFrameTime: TimeInterval = 0
    var amountToMove: CGFloat = 600.0
    
    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        } else {
            detlaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = amountToMove * CGFloat(detlaFrameTime)
        self.enumerateChildNodes(withName: "Background") {
            background, stop in
            
            if  self.currentGameState == gameState.duringGame {
                background.position.y -= amountToMoveBackground
            }
            
            if background.position.y < -self.size.height {
                background.position.y += self.size.height * 2
            }
        }
    }
}
