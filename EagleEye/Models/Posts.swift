//
//  Posts.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/30/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Posts{
    var postArray: [Post] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(location: Location, completed: @escaping ()->()){
        guard location.documentID != "" else{
            return
        }
        db.collection("locations").document(location.documentID).collection("posts").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.postArray = []
            for document in querySnapshot!.documents {
                let post = Post(dictionary: document.data())
                post.documentID = document.documentID
                self.postArray.append(post)
            }
            completed()
        }
        
        
    }
    
    
    

}
