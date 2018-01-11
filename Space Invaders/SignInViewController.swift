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
    
    @IBOutlet var space: UILabel! //Variable qui reference la première ligne du title
    @IBOutlet var invaders: UILabel! //Variable qui reference la deuxième ligne du title
    @IBOutlet weak var googleButton: GIDSignInButton! //Variable qui reference le bouton Google
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Définir UI délégué de l'objet GIDSignIn
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // Ajuster la taille du bouton Google
        googleButton.style = GIDSignInButtonStyle.wide
        
        // Ajouter text et propriété Kern aux labels
        space.attributedText = NSAttributedString(string: "Space",attributes:[ NSAttributedStringKey.kern: 5])
        invaders.attributedText = NSAttributedString(string: "Invaders",attributes:[ NSAttributedStringKey.kern: 5])
    }
    
    // Action qui est appellé quand on pousse sur le bouton Google
    @IBAction func googleSignin(_ sender: Any) {
        // Cette action permet d'appeler la fonction signIn de l'AppDelegate
        GIDSignIn.sharedInstance().signIn()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
