//
//  LocationDetailViewController.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase

class LocationDetailViewController: UIViewController {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    
    var locationInfo: Location!
    var posts: Posts!
    var likedPostsArray = LikedPosts()
    var likedBuilding: LikedBuilding!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap outside of field
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.delegate = self
        tableView.dataSource = self

        if locationInfo == nil {
            locationInfo = Location()
        }
        likedBuilding = LikedBuilding(locationDocumentID: locationInfo.documentID)
        posts = Posts()
        updateUserInterface()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        posts.loadData(location: locationInfo) {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }
        likedPostsArray.loadData(user: user) {
            self.tableView.reloadData()
        }
    }

    
    func updateUserInterface(){
        nameLabel.text = locationInfo.name
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        checkIfLiked(user: user) { (success) in
            if success{
                print("This is a liked building")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: .none), for: .normal)
                self.locationInfo.liked = 1
            }else{
                print("This is not a liked building")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: .none), for: .normal)
                self.locationInfo.liked = 0
            }
        }
    }

    
    
    func updateFromUserInterface() {
        locationInfo.name = nameLabel.text!
    }
    
    
    func checkIfLiked(user: EagleUser, completion: @escaping (Bool) -> ()){
           let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.documentID).collection("likedbuildings").document(locationInfo.documentID)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromUserInterface()
        switch segue.identifier ?? "" {
        case "AddPost":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! PostViewController
            destination.location = locationInfo
        case "ShowPost":
            let destination = segue.destination as! PostViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.post = posts.postArray[selectedIndexPath.row]
            destination.location = locationInfo
        default:
            print("Couldn't find a case for segue identifier \(segue.identifier). This should not have happened")
        }
        
    }
    
    func saveCancelAlert(tite: String, message: String, segueIdentifier: String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.locationInfo.saveData { (success) in
                self.performSegue(withIdentifier: segueIdentifier, sender: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func sortBasedOnSegmentPressed(){
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            posts.postArray.sort(by: {$0.datePosted > $1.datePosted})
        case 1:
            posts.postArray.sort(by: {$0.likes > $1.likes})
        default:
            print("HEY, you shouldn't have gotten here. Check out the segmented control for an error.")
        }
        tableView.reloadData()
    }
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        if locationInfo.documentID == "" {
            saveCancelAlert(tite: "This Building's Like Status Has Not Been Saved", message: "You must hit save before you can add a post", segueIdentifier: "AddPost")
        }else{
            performSegue(withIdentifier: "AddPost", sender: nil)
        }
    }
    
    
    @IBAction func likeButtonPressed(_ sender: Any) {
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        likedBuilding.saveIfNewLike(user: user) { (success) in
            if success{
                print("We are liking this post")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill", withConfiguration: .none), for: .normal)
                self.locationInfo.liked = 1
            }else{
                self.likedBuilding.deleteData(user: user) { (error) in
                    if error == error {
                        print("ERROR Deleting Post")
                        return
                    }
                }
                print("We are unliking this post")
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup", withConfiguration: .none), for: .normal)
                self.locationInfo.liked = 0
            }
        }
    }

        
    
    
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    func leaveViewController(){
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        }else{
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func saveButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        print("SAVE BUTTON PRESSED")
        locationInfo.saveData { (success) in
            if success{
                self.leaveViewController()
            }else{
                self.oneButtonAlert(title: "Save Failed", message: "For some reason, the data would not save to the cloud.")
            }
        }
    }
    
}

extension LocationDetailViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.postArray.count
          }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! LocationDetailTableViewCell
        cell.location = locationInfo
        cell.post = posts.postArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

}
