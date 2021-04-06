//
//  oneArtwork.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 11/5/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import Foundation

struct oneArtwork: Identifiable {
    var id: String
    var name: String
    var image: String
    var artist: String
    var description: String
    var weekDescription: String
    var weekTitle: String
    var buzzwords: [String: String]
    var day: Int!
    var month: Int!
    
}
