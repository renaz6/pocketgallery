//
//  WorkDetailViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 12/2/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import Firebase
import CTSlidingUpPanel
import SwiftUI

class WorkDetailViewController: UIViewController {
    
    var work: ArtworkDataType!
    var dataSource: artworkDataSource!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var titleOutlet: UILabel!
    @IBOutlet weak var artistOutlet: UILabel!
    @IBOutlet weak var buzz1Outlet: UIButton!
    @IBOutlet weak var buzz2Outlet: UIButton!
  
    @IBOutlet weak var descriptionOutlet: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    var userEmail: String!
    var starred: Bool! = false
    private var url = String()
    var saveButtonImage = UIImage(named: "saveButton")
    @IBOutlet weak var bottomView: UIView!
    var bottomController:CTBottomSlideController?;
    var keys: [String]!
    var buzzwords:[String:String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let workData = work!
        dataSource = AppDelegate.instance.dataSource
        
        Auth.auth().addStateDidChangeListener { auth, user in
            if user != nil {
                self.userEmail = user!.email!
            }
        }
        
        titleOutlet.text = work.title
        artistOutlet.text = work.artist
        url = work.image
        descriptionOutlet.text = work.description
        buzzwords = work.buzzwords
        keys = Array(buzzwords.keys)
        if(keys.count>=1)
        {
            buzz1Outlet.setTitle(keys[0], for: .normal)
        }
        
        if(keys.count>=2){
            buzz2Outlet.setTitle(keys[1], for: .normal)
        }
       
        saveButton.setImage(saveButtonImage, for: .normal)
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
        
        // Bottom Controller
        if bottomView != nil {
             bottomController = CTBottomSlideController(parent: view, bottomView: bottomView,
                                                        tabController: self.tabBarController,
                             navController: self.navigationController, visibleHeight: 160)
             //0 is bottom and 1 is top. 0.5 would be center
             bottomController?.setAnchorPoint(anchor: 0.7);
        }
        

    }
    
    // Supports changes in screen orientation for bottom view
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        bottomController?.viewWillTransition(to: size, with: coordinator)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        // Saving a work
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
    
    @IBAction func buzzword1Clicked(_ sender: Any)
    {
        let word = keys[0]
        let alert = UIAlertController(title: word, message: buzzwords[word], preferredStyle: .alert)
        self.present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @objc func alertControllerBackgroundTapped()
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buzzword2Clicked(_ sender: Any)
    {
        let word = keys[1]
        let alert = UIAlertController(title: word, message: buzzwords[word], preferredStyle: .alert)
        self.present(alert, animated: true, completion:{
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertControllerBackgroundTapped)))
        })
    }
    
    @IBAction func imageTapeed(_ sender: UITapGestureRecognizer) {
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
    
    
    
}
