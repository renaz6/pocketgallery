//
//  SettingsViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/20/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import CoreData
import Firebase

protocol LoggedIn {
    func isNowSignedIn(withDisplayName: String?)
}

class SettingsViewController: UIViewController, LoggedIn {
    
    var signedIn = true
    let sectionTitles = ["User Account", "Miscellaneous"]
    var delegate: UIViewController!
    var settings: [NSManagedObject] = []
    var userEmail: String = "user@example.com"
    var displayName: String = "User Name"
    let changeDetailVC: String = "changeDetailSegue"
    let changePasswordVC: String = "ChangePasswordSegue"

    override func viewDidLoad() {
        super.viewDidLoad()

       Auth.auth().addStateDidChangeListener { auth, user in
           if user != nil {
               self.userEmail = user!.email!
               if let name = user?.displayName {
                   self.displayName = name
               }
           }
           
       }
    }
    
    @IBAction func signOutClicked(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error)
        }
        navigationController?.popViewController(animated: true)
    }
    
   func isNowSignedIn(withDisplayName displayName: String?) {
       signedIn = true
       if let name = displayName {
           self.displayName = name
       }
       if delegate != nil {
           let otherVC = self.delegate as! LogIn
           otherVC.signedIn(withDisplayName: displayName)
       }
   }

}
