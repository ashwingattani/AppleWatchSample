//
//  ViewController.swift
//  HeartRateSample
//
//  Created by Ashwin Gattani on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import WatchConnectivity

class ViewController: UIViewController {
    let healthKitManager = HealthKitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
 
    @IBAction func authorizeHealthKit(_ sender: Any) {
        self.healthKitManager.authorizeHealthKit()
    }
    
   
    
    private func playVideo() {
        guard let path = Bundle.main.path(forResource: "video", ofType:"mp4") else {
            debugPrint("video.m4v not found")
            return
        }
        let player = AVPlayer(url: URL(fileURLWithPath: path))
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            player.play()
        }
    }
}

