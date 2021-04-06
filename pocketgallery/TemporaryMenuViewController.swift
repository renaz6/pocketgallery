//
//  TemporaryMenuViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 10/16/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

protocol NotLoggedIn {
    func isLogged(withDisplayName: String?)
}

class TemporaryMenuViewController: UIViewController {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var logoutOutlet: UIButton!
    @IBOutlet weak var loginRegisterButton: UIButton!
    @IBOutlet weak var repeatPassword: UITextField!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    @IBAction func valueChanged(_ sender: Any) {
        changeInterfaceAccoringto(loginRegisterSegmentedControl.selectedSegmentIndex)
    }

    private var loggedIn = false
    var delegate: UIViewController!
    var logInDelegate: UIViewController!
    var settingsDelegate: UIViewController!
    var theMessage = ""
    private var displayName = ""
    
    var firestore = Firestore.firestore()
    
    @objc func handleLogin() {
        Auth.auth().signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { user, error in
            if let error = error, user == nil {
                let alert = UIAlertController(
                title: "Sign in failed",
                message: error.localizedDescription,
                preferredStyle: .alert)

                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
            } else {
                print("Login Successful!")
                
                let alert = UIAlertController(
                title: "Sign in Successful!",
                message: "Welcome.",
                preferredStyle: .alert)
                
                if self.logInDelegate != nil {
                    let otherVC = self.logInDelegate as! NotLoggedIn
                    otherVC.isLogged(withDisplayName: self.nameField.text)
                }

                alert.addAction(UIAlertAction(title:"OK",style:.default))
                self.present(alert, animated: true, completion: nil)
                
                if let navigator = self.navigationController {
                    navigator.popViewController(animated: true)
                }
            }
        }
        
    }
    
    @objc func handleRegister(){
        guard let email = emailField.text,
              let password = passwordField.text,
              let repeatPass = repeatPassword.text,
              email.count > 0,
              password.count > 0,
              repeatPass.count > 0
        else {
            return
        }
        if password == repeatPass {
            Auth.auth().createUser(withEmail: email, password: password) { user, error in
                if error == nil, let userInfo = user {
                    // add display name
                    let changeRequest = userInfo.user.createProfileChangeRequest()
                    changeRequest.displayName = self.nameField.text
                    changeRequest.commitChanges { error in
                        print("Error setting display name: ", error ?? "")
                    }
                    // create entry (saved events) in database
                   self.firestore.collection("users").document(userInfo.user.uid).setData(["savedWorks": []])
                    
                    if self.delegate != nil {
                        let otherVC = self.delegate as! LogIn
                        otherVC.signedIn(withDisplayName: self.emailField.text)
                    }
                    if self.logInDelegate != nil {
                        let otherVC = self.logInDelegate as! NotLoggedIn
                        otherVC.isLogged(withDisplayName: self.emailField.text)
                        self.theMessage = "You will be returned to My Events."
                    }
                    if self.settingsDelegate != nil {
                        let otherVC = self.settingsDelegate as! LoggedIn
                        self.theMessage = "You will be returned to Settings."
                        otherVC.isNowSignedIn(withDisplayName: self.emailField.text)
                    }
                    self.view.endEditing(false)
                    let alert = UIAlertController(
                        title: "Sign Up Successful",
                        message: self.theMessage,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title:"OK", style: .default) { action in
                        // return them to the last screen
                        if let navigator = self.navigationController {
                            navigator.popViewController(animated: true)
                        }
                    })
                    self.present(alert, animated: true)
                } else {
                    let alert = UIAlertController(
                        title: "Error",
                        message: error?.localizedDescription,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
            }
        } else {
            let alert = UIAlertController(
                title: "Passwords do not match",
                message: "Please make sure passwords are the same",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.loggedIn = (user != nil)}

            changeInterfaceAccoringto(loginRegisterSegmentedControl.selectedSegmentIndex)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if(!loggedIn){
            logoutOutlet.isHidden = true
        }
        else{
            loginRegisterSegmentedControl.isHidden = true
            loginRegisterButton.isHidden = true
            nameField.isHidden = true
            emailField.isHidden = true
            passwordField.isHidden = true
        }
    }
    
    func changeInterfaceAccoringto(_ index:Int){

        /*Remove all targets before add*/
        loginRegisterButton.removeTarget(nil, action: nil, for: .allEvents)

        switch index {
        case 0:
            nameField.isHidden = true
            repeatPassword.isHidden = true
            loginRegisterButton.setTitle("Login", for: UIControl.State())
            loginRegisterButton.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        case 1:
            nameField.isHidden = false
            repeatPassword.isHidden = false
            loginRegisterButton.setTitle("Register", for: UIControl.State())
            loginRegisterButton.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        default:
            break;
        }
    }
    
    @IBAction func savedButtonClicked(_ sender: Any) {
    }
    @IBAction func settingsButtonClicked(_ sender: Any) {
        do {
                   try Auth.auth().signOut()
               } catch {
                   print(error)
               }
               navigationController?.popViewController(animated: true)
                let alert = UIAlertController(
                        title: "Update",
                        message: "Logout succesful.",
                        preferredStyle: .alert
                    )
        alert.addAction(UIAlertAction(title: "Return to home.", style: .default, handler: { action in self.performSegue(withIdentifier: "menuToHome", sender: self) }))
                    self.present(alert, animated: true)
                }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == "toSavedSegue"
        {
            if(loggedIn){
                let dest = segue.destination as? SavedViewController
               
            }
            else{
                let alert = UIAlertController(
                        title: "Forbidden",
                        message: "Please sign-in to access saved items.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            }
        else if segue.identifier == "toSettingsSegue"
        {
            if(loggedIn){
                let dest = segue.destination as? SettingsViewController
                
            }
            else{
                let alert = UIAlertController(
                        title: "Forbidden",
                        message: "Please sign-in to access settings.",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(alert, animated: true)
                }
                
            }
            
            
    }
                
               
    // code to dismiss keyboard when user clicks on background
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    

    func isLogged(withDisplayName: String?) {
        if (delegate != nil) {
            let otherVC = self.delegate as! LogIn
            otherVC.signedIn(withDisplayName: displayName)
        }
    }

}

