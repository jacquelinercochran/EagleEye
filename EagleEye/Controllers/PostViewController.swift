//
//  PostViewController.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/30/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .none
    return dateFormatter
}()

class PostViewController: UIViewController {
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var deletePostButton: UIButton!
    @IBOutlet weak var photoButton: UIBarButtonItem!
    
    var post: Post!
    var location: Location!
    var likedPost: LikedPost!
    var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard location != nil else{
            print("ERROR: No location passed")
            return
        }
        if post == nil {
            post = Post()
        }
        likedPost = LikedPost(postDocumentID: post.documentID)
        updateUserInterface()
        imagePickerController.delegate = self
    }
    
    
    func updateUserInterface(){
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        if post.post == ""{
            print("New post!")
        }else{
            checkIfLiked(user: user) { (success) in
                 if success{
                     print("This is a liked post")
                     self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: .none), for: .normal)
                     self.post.liked = 1
                 }else{
                    print("This is not a liked post")
                    self.likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: .none), for: .normal)
                    self.post.liked = 0
                 }
             }
        }

        postTextView.text = post.post
        dateLabel.text = "posted: \(dateFormatter.string(from: post.datePosted))"
        postImageView.image = post.image
        if post.documentID == ""{
            addBordersToEditableObjects()
        }else{
            if post.postUserID == Auth.auth().currentUser?.uid {
                self.navigationItem.leftItemsSupplementBackButton = false
                saveButton.title = "Update"
                addBordersToEditableObjects()
                deletePostButton.isHidden = false
            }else{
                self.navigationItem.leftItemsSupplementBackButton = false
                deletePostButton.isHidden = true
                postTextView.isEditable = false
                postTextView.backgroundColor = .white
                photoButton.hide()
            }
        }
    }
    
    func addBordersToEditableObjects(){
        postTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func updateFromUserInterface(){
        post.post = postTextView.text!
        post.image = postImageView.image!
    }
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func deletePostButtonPressed(_ sender: UIButton) {
        post.deleteData(location: location) { (success) in
            if success{
                self.leaveViewController()
            }else{
                print("Delete unsuccessful")
            }
        }
    }
    
    func showAlert(title: String, message: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        post.saveData(location: location) { (success) in
            if success {
                print("Sucess")
            }else{
                print("ERROR")
            }
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessLibrary()
        }
        let cameraAlertAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAlertAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func checkIfLiked(user: EagleUser, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.documentID).collection("likedposts").document(post.documentID)
        userRef.getDocument{ (document, error) in
            guard error == nil else{
                print("ERROR")
                return completion(false)
            }
            guard document?.exists == true else {
                return completion(false)
            }
            return completion(true)
        }
    }
    
    @IBAction func likeButtonPressed(_ sender: UIButton) {
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        likedPost.saveIfNewLike(user: user) { (success) in
            if success{
                print("We are liking this post")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: .none), for: .normal)
                self.post.liked = 1
                self.post.likes += 1
            }else{
                self.likedPost.deleteData(user: user) { (error) in
                    if error == error {
                        print("ERROR Deleting Post")
                        return
                    }
                }
                print("We are unliking this post")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: .none), for: .normal)
                self.post.liked = 0
                self.post.likes -= 1
            }
        }

    }
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        post.saveData(location: location) { (success) in
            if success {
                self.leaveViewController()
            }else{
                print("ERROR")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    

    
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            post.image = editedImage
        }else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            post.image = originalImage
        }
        updateUserInterface()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessLibrary(){
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera(){
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        }else{
            self.oneButtonAlert(title: "Camera Not Available", message: "There is no camera available on this device.")
        }
    }
}
