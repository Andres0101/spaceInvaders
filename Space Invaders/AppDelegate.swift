//
//  AppDelegate.swift
//  Space Invaders
//
//  Created by etu on 27/11/2017.
//  Copyright © 2017 Andres Bonilla. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?
    var databaseRef: DatabaseReference!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        
        // Définir clienId sur l'utilisateur qui tente de se connecter
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        // Définir lui même en tant que délégué
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }
    
    // Cette fonction permet de gérer l'URL que l'application reçoit à la fin du processus d'authentification
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url,                                                 sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                 annotation: [:])
    }
    
    // Cette fonction permet de se connecter à Google
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        // Valider qu'il n'y a pas d'erreur
        if (error == nil) {
            guard let authentication = user.authentication else { return }
            // Obtenir les credentials d'authentification de Google
            let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                           accessToken: authentication.accessToken)
            
            // Valider que l'utilisateur fait la connection avec le credentials
            Auth.auth().signIn(with: credential) { (user, error) in
                if let error = error {
                    print(error)
                    return
                }
                
                // L'utilisateur est connecté
                self.databaseRef = Database.database().reference()
                // Consulter l'id de l'utilisateur qui vient de se connecter
                self.databaseRef.child("user").child(user!.uid).observeSingleEvent(of: .value, with: {(snapshot) in
                    let snapshot = snapshot.value as? NSDictionary
                    // Si l'utilisateur n'existe pas dans la BDD alors on l'ajoute
                    if(snapshot == nil) {
                        // Champ pour le nom
                        self.databaseRef.child("user").child(user!.uid).child("name").setValue(user?.displayName)
                        // Champ pour le mail
                        self.databaseRef.child("user").child(user!.uid).child("email").setValue(user?.email)
                        // Champ pour le score
                        self.databaseRef.child("user").child(user!.uid).child("score").setValue(0)
                    } else {
                        self.window?.rootViewController?.performSegue(withIdentifier: "HomeViewSegue", sender: nil)
                    }
                })
            }
        } else {
            print("\(error.localizedDescription)")
        }
    }
    
    // Cette fonction permet de se déconnecter de Google
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // Perform any operations when the user disconnects from app here.
        // ...
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

