//
//  GameViewController.swift
//  Space Invaders
//
//  Created by etu on 27/11/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import AVFoundation

class GameViewController: UIViewController {
    
    var backgroundAudio = AVAudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filePath = Bundle.main.path(forResource: "backgroundAudio", ofType: "mp3")
        let audioURL = URL(fileURLWithPath: filePath!)
        
        //Assurer que l'audio existe
        do {
            backgroundAudio = try AVAudioPlayer(contentsOf: audioURL)
        } catch {
            return print("File not found")
        }
        
        backgroundAudio.numberOfLoops = -1
        backgroundAudio.play()
        
        if let view = self.view as! SKView? {
            let scene = GameScene(size: CGSize(width: 1536, height: 2048))
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = false
            view.showsNodeCount = false
        }
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
