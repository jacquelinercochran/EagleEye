//
//  Locations.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class EagleUsers {
    var userArray: [EagleUser] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    func loadData(completed: @escaping ()->()){
        db.collection("users").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.userArray = []
            for document in querySnapshot!.documents {
                let user = EagleUser(dictionary: document.data())
                user.documentID = document.documentID
                self.userArray.append(user)
            }
            completed()
        }
        
    }
    
}

