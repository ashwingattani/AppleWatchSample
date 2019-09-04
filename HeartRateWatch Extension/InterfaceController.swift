//
//  InterfaceController.swift
//  HeartRateWatch Extension
//
//  Created by Atinderpal Singh on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import UserNotifications

class InterfaceController: WKInterfaceController {
    let healthKitManager = HealthKitManager()
    @IBOutlet weak var lblHeartRate: WKInterfaceLabel!
    var dataFetchTimer = Timer()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMoviePlayer), name: NSNotification.Name (rawValue: "showMoviePlayer"), object: nil)
        // Configure interface objects here.
        //   self.sendNotification()
        self.dataFetchTimerStart()
    }
    
    func dataFetchTimerStart() {
        self.dataFetchTimer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(self.fetchHealthKitData),
            userInfo: nil,
            repeats: true)
    }
    
    func dataFetchTimerStop() {
            self.dataFetchTimer.invalidate()
    }
    
    
  @objc func fetchHealthKitData() {
        healthKitManager.fetchHealthData { (sound, health) in
                        if let fetchedSamples = health.samples as? [HKQuantitySample]
                        {
                            let lastHeartRate = fetchedSamples[fetchedSamples.count - 1]
                            let hRate:Double = lastHeartRate.quantity.doubleValue(for: health.heartRateUnit)
                            self.lblHeartRate.setText(String("Heart Rate: \(hRate)"))
                            print("HRate is =\(hRate)")
                            if hRate >= 60.0 {
                                self.sendNotification()
                            }
            }
        }
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func stringWithUUID() -> String {
        let uuidObj = CFUUIDCreate(nil)
        let uuidString = CFUUIDCreateString(nil, uuidObj)!
        return uuidString as String
    }
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate increasing above 60"
        content.subtitle = "hkjkj"
        content.body = "Take Rest"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: self.stringWithUUID(), content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc func showMoviePlayer() {
       // moviePlayer.setHidden(false)
        let url = Bundle.main.url(forResource: "movieclip",
                                  withExtension: "mov")!
                let options = [WKMediaPlayerControllerOptionsAutoplayKey : "true"]
        
                presentMediaPlayerController(with: url, options: options, completion: { didPlayToEnd, endTime, error in
        
                    print(error?.localizedDescription ?? "success")
                })
        
    }
  
}
