//
//  Minus2ViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/6/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import SideMenu
import CTSlidingUpPanel
import SwiftUI
import Firebase

class Minus2ViewController: UIViewController {
    
    var bottomController:CTBottomSlideController?;
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var artistOutlet: UILabel!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var buzz1Outlet: UIButton!
    @IBOutlet weak var buzz2Outlet: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var descriptionOutlet: UITextView!
    
    private var dataSource: artworkDataSource!
    var work: ArtworkDataType!
    var starred: Bool! = false
    
    private var arr = [ArtworkDataType]()
    private var url = String()
    var saveButtonImage = UIImage(named: "saveButton")
    var userEmail: String!
      @ObservedObject private var viewModel = ArtworkViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

       let menuRightNavigationController = SideMenuNavigationController(rootViewController: HomeViewController());
       SideMenuManager.default.rightMenuNavigationController = menuRightNavigationController;
       menuRightNavigationController.presentationStyle = .menuSlideIn;
        
        dataSource = AppDelegate.instance.dataSource
        
        self.viewModel.fetchData { arr in
            self.arr = arr
            self.work = self.arr[currentArtNum-2]
        

             DispatchQueue.main.async {
                 self.titleOutlet.text = self.work.title
                 self.artistOutlet.text = self.work.artist
                 self.url = self.work.image
                 self.descriptionOutlet.text = self.work.description
                self.buzz1Outlet.setTitle(self.work.buzz1, for: .normal)
                self.buzz2Outlet.setTitle(self.work.buzz2, for: .normal)
                self.saveButton.setImage(self.saveButtonImage, for: .normal)
                self.dataSource.isWorkStarred(withId: (self.work.id)) { starred in
                    self.starred = starred
                    if starred {
                        self.saveButtonImage = UIImage(named: "filledSaveButton")
                        self.saveButton.setImage(self.saveButtonImage, for: .normal)
                    }
                }

                 let url2 = URL(string: self.url)

                 DispatchQueue.global().async {
                     let data = try? Data(contentsOf: url2!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                     DispatchQueue.main.async {
                         self.imageOutlet.image = UIImage(data: data!)
                     }
                 }
              
             }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        dataSource = AppDelegate.instance.dataSource
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.userEmail = user!.email!
            }
        }
    // Bottom Controller
    if bottomView != nil {
         bottomController = CTBottomSlideController(parent: view, bottomView: bottomView,
                                                    tabController: self.tabBarController,
                         navController: self.navigationController, visibleHeight: 160)
         //0 is bottom and 1 is top. 0.5 would be center
         bottomController?.setAnchorPoint(anchor: 0.7);
    }
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        // Saving an event
        if saveButtonImage == UIImage(named: "saveButton") {
            
            if(userEmail != nil) {
                
                // Add the starred events
                dataSource.setWorkStarred(withId: work.id, starred: true) { newState in
                    // if newState == true, we successfully starred the event
                    if newState {
                        self.saveButtonImage = UIImage(named: "filledSaveButton")
                        self.saveButton.setImage(self.saveButtonImage, for: .normal)
                        
                        // Alert user about saved event
                        let alert = UIAlertController(title: "Artwork Saved.", message: "You've saved this artwork to your profile.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            }
            else {
                
                // Alert user to sign in
                let alert = UIAlertController(title: "Please Sign In.", message: "Please sign in or make an account to save this artwork.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
            
        }
        else { // Unsaving an event
            
            dataSource.setWorkStarred(withId: work.id, starred: false) { newState in
                // if newState == false, we successfully unstarred the event
                if !newState {
                    self.saveButtonImage = UIImage(named: "saveButton")
                    self.saveButton.setImage(self.saveButtonImage, for: .normal)
                }
            }
        }
        
    }
    
    @IBAction func buzzword1Clicked(_ sender: Any) {
        let word = self.work.buzz1
        let alert = UIAlertController(title: word, message: self.work.def1, preferredStyle: .alert)
        self.present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @IBAction func buzzword2Clicked(_ sender: Any) {
        let word = self.work.buzz2
        let alert = UIAlertController(title: word, message: self.work.buzz2, preferredStyle: .alert)
        self.present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "minus2Forwards"{
            let dest = segue.destination as? YesterdayViewController;}
        if segue.identifier == "2Backwards" {
            let dest = segue.destination as? Minus3ViewController;
        }
            
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
           if identifier == "2Backwards"{
               if (currentArtNum-3 > -1){
                   return true
               }
               else{
                   return false
               }
           }
           return true
           
       }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
