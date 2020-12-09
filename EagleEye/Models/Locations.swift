//
//  Locations.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import Foundation
import Firebase

class Locations {
    var locationArray: [Location] = []
    var db: Firestore!
    
    init(){
        db = Firestore.firestore()
    }
    
    
    var locations = ["Bapst", "St.Mary's", "Gasson", "Lyons", "Stokes", "McElroy", "Carney", "Fulton", "McGuinn", "Devlin", "Campion", "Merkert", "Higgins", "O'Neill", "Maloney", "Conte", "Alumni Stadium", "Roncalli", "Welch", "Williams", "Gonzaga", "Fitzpatrick", "Cheverus", "O'Connell", "Kostka", "Shaw", "Medeiros", "Claver", "Loyola", "Xavier", "Fenwick", "Voute", "Ignacio", "Rubenstein", "Gabelli", "Sixty-Six", "Ninety", "Robsham", "Corcoran", "Mods", "Vanderslice", "Stayer", "Plex", "Walsh", "Thomas Moore Apartments", "Reservoir Apartments", "Greycliff", "Cadigan", "Simboli", "Dance Studio", "St.John's Seminary", "St.Ignatius Church", "St.Clement's Hall", "Law Library", "Stuart", "Barat", "Trinity Chapel", "Hardy", "Cushing", "Duchesne", "Keyes", "Quonset Hut"]
    
    func loadData(completed: @escaping ()->()){
        db.collection("locations").addSnapshotListener { (querySnapshot, error) in
            guard error == nil else{
                print("ERROR: adding the snapcshot listener \(error!.localizedDescription)")
                return completed()
            }
            self.locationArray = []
            for document in querySnapshot!.documents {
                let location = Location(dictionary: document.data())
                location.documentID = document.documentID
                self.locationArray.append(location)
            }
            completed()
        }
        
    }
    
    
    func setData(){
       locations.sort(by: <)
        //does this work when there is actual data and its not the first time running?
        for location in locations{
            locationArray.append(Location(name: location, numberOfPosts: 0, liked: 0, documentID: "", postingUserID: ""))
            locationArray[locationArray.count - 1].saveData { (success) in
                if success{
                    print("Success")
                }else{
                    print("ERROR saving")
                }
            }
            
        }

    }
}
