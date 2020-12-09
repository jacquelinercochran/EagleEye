//
//  LikedPosts.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/3/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class LikedPost {
    var postDocumentID: String
    
    var dictionary: [String: Any] {
        return ["postDocumentID": postDocumentID]
    }
    
    init(postDocumentID: String){
        self.postDocumentID = postDocumentID
    }
    
    convenience init(){
        self.init(postDocumentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let postDocumentID = dictionary["postDocumentID"] as! String? ?? ""
        self.init(postDocumentID: postDocumentID)
        
    }
    
    func saveIfNewLike(user: EagleUser, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.documentID).collection("likedposts").document(postDocumentID)
        userRef.getDocument{ (document, error) in
            guard error == nil else{
                print("ERROR")
                return completion(false)
            }
            guard document?.exists == false else {
                return completion(false)
            }
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(user.documentID).collection("likedposts").document(self.postDocumentID).setData(dataToSave) { (error) in
                guard error == nil else {
                    print("ERROR \(error?.localizedDescription)")
                    return completion(false)
                }
                return completion(true)
            }
        }
    }
    
    func deleteData(user: EagleUser, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("users").document(user.documentID).collection("likedposts").document(postDocumentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting post documentID \(self.postDocumentID). Error; \(error.localizedDescription)")
                completion(false)
            }else{
                print("Successfully deleted document")
                completion(true)
            }
        }
    }
    
    
    

    
}
