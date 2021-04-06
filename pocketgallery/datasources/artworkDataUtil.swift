//
//  artworkDataUtil.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/22/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import Foundation

extension ArtworkDataType {
    
    var id: String {
        return self["id"] as! String
    }
           
    var title: String {
        return self["name"] as! String
    }
    
    var artist: String {
        return self["artist"] as! String
    }
           
    var image: String {
        return self["image"] as! String
    }

    var description: String {
        return self["description"] as! String
    }
        
    var weekDescription: String {
        return self["weekDescription"] as! String
    }

    var weekTitle: String {
        return self["weekTitle"] as! String
    }
    
    var buzz1: String {
        
        return self["buzz1"] as! String
    }

    var buzz2: String {
        return self["buzz2"] as! String
    }

    var def1: String {
        return self["def1"] as! String
    }

    var def2: String {
        return self["def2"] as! String
    }
    
    var buzzwords: [String:String]{
        return self["buzzwords"] as! [String:String]
    }
    
    var day: Int{
        return self["day"] as! Int
    }
    
    var month: Int{
        return self["month"] as! Int
    }
    
func from(_ aw: oneArtwork) -> ArtworkDataType {
        
    let keys = Array(aw.buzzwords.keys)
 
    var key1: String!
    var key2: String!
    
    if(0 < keys.count)
    {
        key1 = keys[0];
    }
    else{
        key1 = ""
    }
    
    if(1 < keys.count)
    {
        key2 = keys[1];
    }
    else{
        key2 = ""
    }
    
        let work: ArtworkDataType = [
            "id": aw.id,
            "name": aw.name,
            "image": aw.image,
            "artist": aw.artist,
            "description": aw.description,
            "weekDescription": aw.weekDescription,
            "weekTitle": aw.weekTitle,
            "buzz1": key1 ?? "",
            "buzz2": key2 ?? "",
            "def1": aw.buzzwords[key1] ?? "",
            "def2": aw.buzzwords[key2] ?? "",
            "day": aw.day ?? 0,
            "month": aw.month ?? 0,
            "buzzwords": aw.buzzwords
            
        ]
        
        return work
    }
}

