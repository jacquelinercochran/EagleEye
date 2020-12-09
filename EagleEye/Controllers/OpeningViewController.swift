//
//  OpeningViewController.swift
//  EagleEye
//
//  Created by Jackie Cochran on 11/29/20.
//  Copyright © 2020 Jackie Cochran. All rights reserved.
//

import UIKit
import AVFoundation

class OpeningViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var audioPlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playSound(name: "bc-for-boston")
        let originalY: CGFloat = imageView.frame.origin.y
        imageView.frame.origin.y += view.frame.height
        UIView.animate(withDuration: 5.0, animations: {self.imageView.frame.origin.y = originalY}, completion: {(_) in
            self.audioPlayer.stop()
        })
    }
    
    func playSound(name: String){
        print("We are in playsound")
        if let sound = NSDataAsset(name: name){
            do{
                try audioPlayer = AVAudioPlayer(data: sound.data)
                audioPlayer.play()
                print("We are playing music")
            }catch{
                print("ERROR: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
    }
    
}
