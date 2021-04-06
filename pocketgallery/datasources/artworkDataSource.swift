//
//  artworkDataSource.swift
//  pocketgallery
//
//  Created by Serena  Zamarripa on 10/23/20.
//  Copyright © 2020 zamarripa. All rights reserved.
//

import Foundation

protocol artworkDataSource {
    
    func allWorks(completion handler: @escaping ([ArtworkDataType]) -> Void)
    
    func starredWork(completion: @escaping ([ArtworkDataType]) -> Void)
    
    func isWorkStarred(withId: String, completion: @escaping (Bool) -> Void)
    
    func setWorkStarred(withId: String, starred: Bool, completion: @escaping (Bool) -> Void)
}
