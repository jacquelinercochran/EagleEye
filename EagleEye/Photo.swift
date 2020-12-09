//
//  Photo.swift
//  EagleEye
//
//  Created by Jackie Cochran on 12/2/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase

class Photo {
    var image: UIImage
    var date: Date
    var photoUserID: String
    var photoURL: String
    var documentID: String
    
    
    var dictionary: [String: Any] {
        let timeIntervalDate = date.timeIntervalSince1970
        return ["image": image, "date": timeIntervalDate, "photoUserID": photoUserID, "photoURL": photoURL]
    }
    
    init(image: UIImage, date: Date, photoUserID: String, photoURL: String, documentID: String){
        self.image = image
        self.date = date
        self.photoUserID = photoUserID
        self.photoURL = photoURL
        self.documentID = documentID
    }
    
    convenience init(){
        let photoUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(named: "logo") ?? UIImage(), date: Date(), photoUserID: photoUserID, photoURL: "", documentID: "")
        
    }
    
    convenience init(dictionary: [String: Any]) {
        let image = dictionary["image"] as! UIImage? ?? UIImage()
        let timeIntervalDate = dictionary["datePosted"] as! TimeInterval? ?? TimeInterval()
        let date = Date(timeIntervalSince1970: timeIntervalDate)
        let photoUserID = dictionary["photoUserID"] as! String? ?? ""
        let photoURL = dictionary["photoURL"] as! String? ?? ""
        self.init(image: UIImage(), date: date, photoUserID: photoUserID, photoURL: photoURL, documentID: "")
    }
    
    func saveData(location: Location, post: Post, completion: @escaping (Bool) -> ()) {
        let db = Firestore.firestore()
        let storage = Storage.storage()
        
        //convert photo.image to a Data type that it can be saved in Firebase Storage
        guard let photoData = self.image.jpegData(compressionQuality: 0.5) else{
            print("Error: Could not convert photo.image to Data")
            return
        }
        
        //create metadata so that we can see images in the Firebase Storage Console
        let uploadMetaData = StorageMetadata()
        uploadMetaData.contentType = "image/jpeg"
        
        //create a file name if necessary
        if documentID == ""{
            documentID = UUID().uuidString
        }
        
        //create a storage reference to upload this image file to the spot's folder
        let storageRef = storage.reference().child(location.documentID).child(post.documentID).child(documentID)
        
        //create an uploadTask
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("Error: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was successful")
            let dataToSave = self.dictionary
            let ref = db.collection("locations").document(location.documentID).collection("posts").document(post.documentID).collection("photos").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("ERROR: updating document \(error?.localizedDescription)")
                    return completion(false)
                }
            print("Updated document: \(self.documentID)")
            completion(true)
            }
        }
            
            //TODO: update with photoURL for smoother image loading
            
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("Error: Upload task for file \(self.documentID) failed, in spot \(location.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
        
    }
    

}
