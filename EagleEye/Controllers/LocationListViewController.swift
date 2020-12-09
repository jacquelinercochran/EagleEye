//
//  LocationListViewController.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import Firebase

class LocationListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortSegmentedControl: UISegmentedControl!
    
    var locationsArray = Locations()
    var count = 0
    let firstRun = UserDefaults.standard.bool(forKey: "firstRun") as Bool

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        if firstRun {
            print("We've been here before")
        }else{
            runFirst()
        }

    }
    
    func runFirst(){
        print("FIRST RUN")
        UserDefaults.standard.set(true, forKey: "firstRun")
        locationsArray.setData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return
        }
        let user = EagleUser(user: currentUser)
        locationsArray.loadData {
            self.sortBasedOnSegmentPressed()
            self.tableView.reloadData()
        }

    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail"{
            let destination = segue.destination as! LocationDetailViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.locationInfo = locationsArray.locationArray[selectedIndexPath.row]
            //destination.likedBuilding = likedBuildingsArray.likedBuildingArray[selectedIndexPath.row]
        } else {
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                tableView.deselectRow(at: selectedIndexPath, animated: true)
            }
        }
    }
    
    func sortBasedOnSegmentPressed(){
        switch sortSegmentedControl.selectedSegmentIndex {
        case 0:
            locationsArray.locationArray.sort(by: {$0.name < $1.name})
        case 1:
            locationsArray.locationArray.sort(by: {$0.liked > $1.liked})
        default:
            print("HEY, you shouldn't have gotten here. Check out the segmented control for an error.")
        }
        tableView.reloadData()
    }
    
    
    @IBAction func sortSegmentPressed(_ sender: UISegmentedControl) {
        sortBasedOnSegmentPressed()
    }
    
    func checkIfLiked(user: EagleUser, location: Location, completion: @escaping (Bool) -> ()){
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(user.documentID).collection("likedbuildings").document(location.documentID)
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
    
}


extension LocationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locationsArray.locationArray.count
    }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! LocationListTableViewCell
        cell.nameLabel?.text = locationsArray.locationArray[indexPath.row].name
        cell.buildingImage.image = UIImage(named: "\(locationsArray.locationArray[indexPath.row].name)")
        guard let currentUser = Auth.auth().currentUser else {
            print("ERROR")
            return cell;
        }
        let user = EagleUser(user: currentUser)
        checkIfLiked(user: user, location: locationsArray.locationArray[indexPath.row]) { (success) in
            if success{
                print("This is a liked building")
                cell.likedImage.image = UIImage(systemName: "hand.thumbsup.fill")
                self.locationsArray.locationArray[indexPath.row].liked = 1
            }else{
                print("This is not a liked building")
                cell.likedImage.image = UIImage(systemName: "hand.thumbsup")
                self.locationsArray.locationArray[indexPath.row].liked = 0
            }
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
