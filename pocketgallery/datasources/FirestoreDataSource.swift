//
//  FirestoreDataSource.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 10/23/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Firebase
import FirebaseAuth


class FirestoreDataSource: artworkDataSource {
    
     private var firestore = Firestore.firestore()
    
    // MARK: - ArtworkDataSource implementation
   func allWorks(completion handler: @escaping ([ArtworkDataType]) -> Void) {
//        firestore.collection("art")
//            .getDocuments(completion: { result, error in
//                if error == nil, let docs =
//                    result?.documents {
//                    handler(docs.map { $0.data() })
//                }
//            })
        var artworks = [ArtworkDataType]()
        var a: ArtworkDataType!

        firestore.collection("art").addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
            print("No Documents")
            return
        }
            artworks = documents.map { (queryDocumentSnapshot) -> ArtworkDataType in
                    let data = queryDocumentSnapshot.data()

                    print(data)
                    let name = data["name"]
                    let artist = data["artist"]
                    let id = data["id"]
                    let image = data["image"]
                    let description = data["description"]
                    let weekDescription = data["weekDescription"]
                    let weekTitle = data["weekTitle"]
                    let buzzwords = data["buzzwords"]
                    let day = data["day"]
                    let month = data["month"]

                let one = oneArtwork(id: id as? String ?? "", name: name as? String ?? "", image: image as? String ?? "", artist: artist as? String ?? "", description: description as? String ?? "", weekDescription: weekDescription as? String ?? "", weekTitle: weekTitle as? String ?? "", buzzwords: buzzwords as? [String:String] ?? ["":""], day: day as? Int, month: month as? Int)

                return(a.from(one))

                }
                handler(artworks)
            }
      }
    
    
    
    func isWorkStarred(withId id: String, completion handler: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                if let savedWorkIds = doc?.data()?["savedWorks"] as? [String] {
                    handler(savedWorkIds.contains(id))
                }
            }
        } else {
            handler(false)
        }
    }
    
    func setWorkStarred(withId id: String, starred: Bool, completion handler: @escaping (Bool) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                if let savedWorkIds = doc?.data()?["savedWorks"] as? [String] {
                    var savedWorkMutable = savedWorkIds
                    let starredNow = savedWorkMutable.contains(id)
                    
                    if starred, !starredNow {
                        savedWorkMutable.append(id)
                    } else if !starred, let index = savedWorkMutable.firstIndex(of: String(id)) {
                        savedWorkMutable.remove(at: index)
                    }
                    self.firestore.collection("users").document(user.uid).updateData(["savedWorks": savedWorkMutable]) { error in
                        if error == nil {
                            handler(starred)
                        } else {
                            handler(starredNow)
                        }
                    }
                }
            }
        } else {
            handler(false)
        }
    }
    
    
    func starredWork(completion handler: @escaping ([ArtworkDataType]) -> Void) {
        if let user = Auth.auth().currentUser {
            
            firestore.collection("users").document(user.uid).getDocument { doc, error in
                
                if let savedWorkIds = doc?.data()?["savedWork"] as? [String] {
                    if savedWorkIds.isEmpty {
                        handler([])
                    } else {
                        self.firestore.collection("art")
                            .whereField("id", in: savedWorkIds)
                            .getDocuments { result, error in
                                
                                if error == nil, let docs = result?.documents {
                                    
                                    handler(docs.map {($0.data())})
                                }
                        }
                    }
                }
            }
        } else {
            handler([])
        }
    }

}
