//
//  Location.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Location {
    var name: String
    var numberOfPosts: Int
    var liked: Int
    var documentID: String
    var postingUserID: String
    
    var dictionary: [String: Any] {
        return ["name": name, "numberOfPosts": numberOfPosts, "postingUserID": postingUserID, "liked": liked]
    }

    
    init(name: String, numberOfPosts: Int, liked: Int, documentID: String, postingUserID: String){
        self.name = name
        self.numberOfPosts = numberOfPosts
        self.liked = liked
        self.documentID = documentID
        self.postingUserID = postingUserID
    }
    
    convenience init() {
        self.init(name: "", numberOfPosts: 0, liked: 0, documentID: "", postingUserID: "")
    }
    
    convenience init(dictionary: [String: Any]) {
        let name = dictionary["name"] as! String? ?? ""
        let numberOfPosts = dictionary["numberOfPosts"] as! Int? ?? 0
        let liked = dictionary["liked"] as! Int? ?? 0
        let postingUserID = dictionary["postingUserID"] as! String? ?? ""
        self.init(name: name, numberOfPosts: numberOfPosts, liked: liked, documentID: "", postingUserID: postingUserID)
    }
    
    func saveData(completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        //Grab the user ID
        guard let postingUserID = Auth.auth().currentUser?.uid else{
            print("ERROR: Could not save data because we don't have a valid posting User ID")
            return completion(false)
        }
        self.postingUserID = postingUserID
        //create dictionary above to save things in firestore so it knows what to make the keys
        let dataToSave: [String: Any] = self.dictionary
        //if we have saved a record, we have an id, or else we add a document
        if self.documentID == ""{
            var ref: DocumentReference? = nil
            ref = db.collection("locations").addDocument(data: dataToSave){ (error) in
                guard error == nil else{
                    print("ERROR: adding document \(error?.localizedDescription)")
                    return completion(false)
                }
                self.documentID = ref!.documentID
                print("Added document: \(self.documentID)")
                completion(true)
            }
        }else{
            let ref = db.collection("locations").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("ERROR: updating document \(error?.localizedDescription)")
                    return completion(false)
                }
                print("Updated document: \(self.documentID)")
                completion(true)
            }
        }
    }
}

