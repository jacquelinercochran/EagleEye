//
//  LikedBuildings.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/3/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class LikedBuilding {
    var locationDocumentID: String
    
    var dictionary: [String: Any] {
        return ["locationDocumentID": locationDocumentID]
    }
    
    init(locationDocumentID: String){
        self.locationDocumentID = locationDocumentID
    }
    
    convenience init(){
        self.init(locationDocumentID: "")
    }
    
    convenience init(dictionary: [String: Any]){
        let locationDocumentID = dictionary["locationDocumentID"] as! String? ?? ""
        self.init(locationDocumentID: locationDocumentID)
        
    }
    
    func saveIfNewLike(user: EagleUser, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.documentID).collection("likedbuildings").document(locationDocumentID)
        userRef.getDocument{ (document, error) in
            guard error == nil else{
                print("ERROR")
                return completion(false)
            }
            guard document?.exists == false else {
                return completion(false)
            }
            let dataToSave: [String: Any] = self.dictionary
            db.collection("users").document(user.documentID).collection("likedbuildings").document(self.locationDocumentID).setData(dataToSave) { (error) in
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
        db.collection("users").document(user.documentID).collection("likedbuildings").document(locationDocumentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting post documentID \(self.locationDocumentID). Error; \(error.localizedDescription)")
                completion(false)
            }else{
                print("Successfully deleted document")
                completion(true)
            }
        }
    }
    
}
