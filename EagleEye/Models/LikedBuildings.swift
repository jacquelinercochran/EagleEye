//
//  LikedBuildings.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/6/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class LikedBuildings {
    var likedBuildingArray: [LikedBuilding] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }

    func loadData(user: EagleUser, completed: @escaping ()->()){
        guard user.documentID != "" else{
            return
        }
        db.collection("users").document(user.documentID).collection("likedbuildings").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.likedBuildingArray = []
            for document in querySnapshot!.documents {
                let likedBuilding = LikedBuilding(dictionary: document.data())
                likedBuilding.locationDocumentID = document.documentID
                self.likedBuildingArray.append(likedBuilding)
            }
            completed()
        }
        
        
    }
    
}
