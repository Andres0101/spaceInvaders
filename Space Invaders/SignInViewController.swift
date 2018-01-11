//
//  SignInViewController.swift
//  Space Invaders
//
//  Created by etu on 14/12/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class SignInViewController: UIViewController, GIDSignInUIDelegate {

    @IBOutlet var space: UILabel!
    @IBOutlet var invaders: UILabel!
    @IBOutlet weak var googleButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        GIDSignIn.sharedInstance().uiDelegate = self
        
        googleButton.style = GIDSignInButtonStyle.wide
        
        //Ajouter propriété Kern aux labels
        space.attributedText = NSAttributedString(string: "Space",attributes:[ NSAttributedStringKey.kern: 5])
        invaders.attributedText = NSAttributedString(string: "Invaders",attributes:[ NSAttributedStringKey.kern: 5])
    }
    @IBAction func googleSignin(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
