//
//  SavedViewController.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/20/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import SwiftUI

protocol LogIn {
    func signedIn(withDisplayName: String?)
}
class SavedViewController: UIViewController, UITableViewDelegate,UITableViewDataSource, LogIn {
    
    
     private var firestore = Firestore.firestore()
    
    @IBOutlet weak var savedTable: UITableView!
    private var displayName = ""
    private var loggedIn = false
    private var myWorks: [ArtworkDataType] = []
    private var dataSource: artworkDataSource!
     var userEmail: String = "user@example.com"
    var url: String!
       @ObservedObject private var viewModel = ArtworkViewModel()
    @IBOutlet weak var nameLabel: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = AppDelegate.instance.dataSource
        savedTable.delegate = self;
        savedTable.dataSource = self;
        
        Auth.auth().addStateDidChangeListener { auth, user in
            self.loggedIn = (user != nil)
            if self.loggedIn {
                //self.userEmail = (user?.email)!
                self.displayName = user?.displayName ?? ""
                
                // load favourite events if we're logged in
                self.viewModel.starredWork { arr in
                    self.myWorks = arr
                    print(arr)
                   
                    self.savedTable.reloadData()
                    
                    
                }
            }
        }
        nameLabel.text = "Explore Your Saved Works"
    }
    
    override func viewWillAppear(_ animated: Bool) {
if loggedIn {
    
        
                  Auth.auth().addStateDidChangeListener { auth, user in
                 self.loggedIn = (user != nil)
                 if self.loggedIn {
                     //self.userEmail = (user?.email)!
                     self.displayName = user?.displayName ?? ""
                     
                     // load favourite events if we're logged in
                     self.viewModel.starredWork { arr in
                         self.myWorks = arr
                         print(arr)
                        
                         self.savedTable.reloadData()
                         
                         
                     }
                 }
             }
                 }
       }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myWorks.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 533.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         print(indexPath)
        var workData = myWorks[indexPath.row]
       
       let reusableCell = tableView.dequeueReusableCell(withIdentifier: "workCell", for: indexPath)
        if let cell = reusableCell as? SavedWorkTableViewCell {
            cell.index = indexPath.row
            cell.workId = workData.id
            print("id",workData.id)
            //cell.thumbnail.image = UIImage(named: eventData.imageId)
//            cell.title.text = workData.title
//            cell.artist.text = workData.artist
            self.url = workData.image

            let url2 = URL(string: self.url ?? "")

            DispatchQueue.global().async {
                let data = try? Data(contentsOf: url2!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    cell.thumbnail.image = UIImage(data: data!)
                }
            }
            return cell
        } else {
           return reusableCell
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showWorkDetail",
            let dest = segue.destination as? WorkDetailViewController,
            let cell = sender as? SavedWorkTableViewCell {
            dest.work = myWorks[cell.index]
        }
    }
    
    // called by login controller to notify us that the user has logged in,
    // optionally with a specified display name (for new accounts)
    func signedIn(withDisplayName displayName: String?) {
        loggedIn = true
        
        if let name = displayName {
            self.displayName = name
        }
    }
}
