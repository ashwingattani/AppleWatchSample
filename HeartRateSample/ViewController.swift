//
//  ViewController.swift
//  HeartRateSample
//
//  Created by Ashwin Gattani on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let healthKitManager = HealthKitManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func authorizeHealthKit(_ sender: Any) {
        self.healthKitManager.authorizeHealthKit()
    }
}

