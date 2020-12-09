//
//  LocationDetailTableViewCell.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/30/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit

class LocationDetailTableViewCell: UITableViewCell {


    @IBOutlet weak var postLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likesLabel: UILabel!
    
    var location: Location!
    
    var post: Post! {
        didSet{
            post.loadImage(location: location) { (success) in
                if success{
                    if self.post.image == UIImage() {
                        self.postImageView.image = UIImage(named: "logo")
                    }else{
                        self.postImageView.image = self.post.image
                    }
                }else{
                    print("ERROR")
                }
            }
            postLabel.text = post.post
            likesLabel.text = "Likes: \(post.likes)"
        }
    }

    

}
