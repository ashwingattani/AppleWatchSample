//
//  InterfaceController.swift
//  HeartRateWatch Extension
//
//  Created by Ashwin Gattani on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import UserNotifications


class InterfaceController: WKInterfaceController {

    
    @IBOutlet weak var lblHeartRate: WKInterfaceLabel!
//    @IBOutlet weak var moviePlayer: WKInterfaceMovie!

    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    var heartRateQuery:HKQuery?
    
    var observeQuery:HKObserverQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showMoviePlayer), name: NSNotification.Name (rawValue: "showMoviePlayer"), object: nil)
       // self.lblHeartRate.setText("")
     // Configure interface objects here.
        
     //   self.sendNotification()
       // self.fetchHealthRateData()

    }
    
    
    
    func showAlert() {
        self.presentController(withName: "ErrorInterfaceController", context:["title":"yourTitle" , "text":"yourText"])
      
    }
    
    func fetchHealthRateData() {
         heartRateQuery = self.createStreamingQuery()
          health.execute(heartRateQuery!)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        print("willActivate notificationCount == \(notificationCount)")
        
        if notificationCount == 0 {
           self.fetchHealthRateData()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
        print("didDeactivate")
       // notificationCount = 0
    }
    
    private func createStreamingQuery() -> HKQuery
    {
        let queryPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)

        let query = HKAnchoredObjectQuery.init(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) in
            if let errorFound = error {
                print("query error: \(errorFound.localizedDescription)")
            } else {
                //printing heart rate
                if let fetchedSamples = samples as? [HKQuantitySample]
                {
                  //  if fetchedSamples.count > 0 {
                    let lastHeartRate = fetchedSamples[fetchedSamples.count - 1]
                    let hRate:Double = lastHeartRate.quantity.doubleValue(for: self.heartRateUnit)
                    self.lblHeartRate.setText(String("Heart Rate: \(hRate)"))
                    print("HRate is =\(hRate)")
                        if hRate >= 60.0 {
                            self.sendNotification()
                        }
                  //  }
                }
            }
        }
        return query
    }
    
    
    func sendNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate increasing above 60"
        content.subtitle = ""
        content.body = "Take Rest"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @objc func showMoviePlayer() {
       // moviePlayer.setHidden(false)
        let url = Bundle.main.url(forResource: "movieclip",
                                  withExtension: "mov")!
       
        //moviePlayer.setMovieURL(url)
        
        
        
                let options = [WKMediaPlayerControllerOptionsAutoplayKey : "true"]
        
                presentMediaPlayerController(with: url, options: options, completion: { didPlayToEnd, endTime, error in
        
                    print(error?.localizedDescription ?? "success")
                })
        
    }
  
}
