//
//  Post.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Post {
    var image: UIImage
    var post: String
    var likes: Int
    var liked: Int
    var postUserID: String
    var datePosted: Date
    var documentID: String
    
    var dictionary: [String: Any] {
        let timeIntervalDate = datePosted.timeIntervalSince1970
        return ["post":post, "likes":likes, "liked":liked, "postUserID":postUserID, "datePosted":timeIntervalDate]
    }
    
    init(image: UIImage, post: String, likes: Int, liked: Int, postUserID: String, datePosted: Date, documentID: String){
        self.image = image
        self.post = post
        self.likes = likes
        self.liked = liked
        self.postUserID = postUserID
        self.datePosted = datePosted
        self.documentID = documentID
    }
    
    convenience init(){
        let postUserID = Auth.auth().currentUser?.uid ?? ""
        self.init(image: UIImage(named: "logo") ?? UIImage(), post: "", likes: 0, liked: 0, postUserID: postUserID, datePosted: Date(), documentID: "")
        
    }
    
    convenience init(dictionary: [String: Any]) {
        let image = dictionary["image"] as! UIImage? ?? UIImage()
        let post = dictionary["post"] as! String? ?? ""
        let likes = dictionary["likes"] as! Int? ?? 0
        let liked = dictionary["liked"] as! Int? ?? 0
        let postUserID = dictionary["postUserID"] as! String? ?? ""
        let timeIntervalDate = dictionary["datePosted"] as! TimeInterval? ?? TimeInterval()
        let datePosted = Date(timeIntervalSince1970: timeIntervalDate)
        self.init(image: image, post: post, likes: likes, liked: liked, postUserID: postUserID, datePosted: datePosted, documentID: "")
    }
    
    func saveData(location: Location, completion: @escaping (Bool) -> ()) {
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
        let storageRef = storage.reference().child(location.documentID).child(documentID)
        print("\(storageRef)")
        //create an uploadTask
        let uploadTask = storageRef.putData(photoData, metadata: uploadMetaData) { (metadata, error) in
            if let error = error {
                print("Error: upload for ref \(uploadMetaData) failed. \(error.localizedDescription)")
            }
        }
        
        uploadTask.observe(.success) { (snapshot) in
            print("Upload to Firebase Storage was successful")
            let dataToSave = self.dictionary
            let ref = db.collection("locations").document(location.documentID).collection("posts").document(self.documentID)
            ref.setData(dataToSave) { (error) in
                guard error == nil else{
                    print("ERROR: updating document \(error?.localizedDescription)")
                    return completion(false)
                }
            print("Updated document: \(self.documentID)")
            completion(true)
            }
        }
            
            
        
        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                print("Error: Upload task for file \(self.documentID) failed, in spot \(location.documentID), with error \(error.localizedDescription)")
            }
            completion(false)
        }
        
    }
    


    
    
    func deleteData(location: Location, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        db.collection("locations").document(location.documentID).collection("posts").document(documentID).delete { (error) in
            if let error = error {
                print("ERROR: deleting post documentID \(self.documentID). Error; \(error.localizedDescription)")
                completion(false)
            }else{
                print("Successfully deleted document")
                completion(true)
            }
        }
    }
    
    func loadImage(location: Location, completion: @escaping (Bool) -> ()) {
        guard location.documentID != "" else{
            print("ERROR: Did not bring a valid location")
            return
        }
        let storage = Storage.storage()
        let storageRef = storage.reference().child(location.documentID).child(documentID)
        storageRef.getData(maxSize: 25*1024*1024) { (data, error) in
            if let error = error {
                print("ERROR: an error occurred while reading data from file ref: \(storageRef) error = \(error.localizedDescription)")
            }else{
                self.image = UIImage(data: data!) ?? UIImage()
                return completion(true)
            }
        }
    }
    
}
