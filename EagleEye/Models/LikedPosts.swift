//
//  LikedPosts.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/3/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class LikedPosts {
    var likedPostArray: [LikedPost] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }

    func loadData(user: EagleUser, completed: @escaping ()->()){
        guard user.documentID != "" else{
            return
        }
        db.collection("users").document(user.documentID).collection("likedposts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.likedPostArray = []
            for document in querySnapshot!.documents {
                let likedPost = LikedPost(dictionary: document.data())
                likedPost.postDocumentID = document.documentID
                self.likedPostArray.append(likedPost)
            }
            completed()
        }
        
        
    }
    
}
