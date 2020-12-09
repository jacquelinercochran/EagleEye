//
//  Photos.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/2/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Photos{
    var photoArray: [Photo] = []
    
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(location: Location, post: Post, completed: @escaping ()->()){
        guard location.documentID != "" else{
            return
        }
        db.collection("locations").document(location.documentID).collection("posts").document(post.documentID).collection("photos").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.photoArray = []
            for document in querySnapshot!.documents {
                let photo = Photo(dictionary: document.data())
                photo.documentID = document.documentID
                self.photoArray.append(photo)
            }
            completed()
        }
        
    }
    

}
