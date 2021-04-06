//
//  ArtworkViewModel.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/5/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth
import Firebase

class ArtworkViewModel: ObservableObject{
    @Published var artworks = [ArtworkDataType]()

    private var db = Firestore.firestore()

    func fetchData(completionHandler: @escaping ([ArtworkDataType]) -> Void) {
        
        var artworks = [ArtworkDataType]()
        var a = ArtworkDataType()

        db.collection("art").addSnapshotListener { (querySnapshot, error) in
        guard let documents = querySnapshot?.documents else {
            return
        }
            artworks = documents.map { (queryDocumentSnapshot) -> ArtworkDataType in
                    let data = queryDocumentSnapshot.data()

                 
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

                completionHandler(artworks)
            }

//        db.collection("art").addSnapshotListener { (querySnapshot, error) in
//            guard let documents = querySnapshot?.documents else {
//                print("No Documents")
//                return
//            }
//
//            self.artworks = documents.map { (queryDocumentSnapshot) -> oneArtwork in
//                let data = queryDocumentSnapshot.data()
//
//                print(data)
//                let name = data["name"]
//                let artist = data["artist"]
//                let id = data["id"]
//                let image = data["image"]
//                let description = data["description"]
//                let weekDescription = data["weekDescription"]
//                let weekTitle = data["weekTitle"]
//                let buzzwords = data["buzzwords"]
//
//                return oneArtwork(id: id as? String ?? "", name: name as? String ?? "", image: image as? String ?? "", artist: artist as? String ?? "", description: description as? String ?? "", weekDescription: weekDescription as? String ?? "", weekTitle: weekTitle as? String ?? "", buzzwords: buzzwords as? [String:String] ?? ["":""])
//
//            }
//
//            print(self.artworks.count)
//            completionHandler(self.artworks)
//        }

    }
    
    func starredWork(completion handler: @escaping ([ArtworkDataType]) -> Void) {
        let user1 = Auth.auth().currentUser
        if let user = Auth.auth().currentUser {
            db.collection("users").document(user.uid).getDocument { doc, error in
                
                if let savedWorkIds = doc?.data()?["savedWorks"] as? [String] {
                    if savedWorkIds.isEmpty {
                        handler([])
                    } else {

                        self.db.collection("art")
                            .whereField("id", in: savedWorkIds)
                            .getDocuments { result, error in
                                if error == nil, let docs = result?.documents {
                            
                                    handler(docs.map {($0.data())})
                                }
                        }
                    }
                }
            }
        }
        else {
            handler([])
        }
    }
    
    func work(withId id: String, completion handler: @escaping (ArtworkDataType?) -> Void) {
        // a single event with this ID, or nil
        let docRef = db.collection("art").document(id)
        
        docRef.getDocument { doc, error in
            if let error = error {
                print("Could not fetch artwork", id, error)
            } else {
                handler(doc?.data())
            }
        }
    }
    
    
}
