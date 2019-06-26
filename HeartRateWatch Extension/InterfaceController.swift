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
    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    var heartRateQuery:HKQuery?
    
    var observeQuery:HKObserverQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        self.sendNotification()
        
        
//        heartRateQuery = self.createStreamingQuery()
//        health.execute(heartRateQuery!)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
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
                   let lastHeartRate = fetchedSamples[fetchedSamples.count - 1]
                    let hRate:Double = lastHeartRate.quantity.doubleValue(for: self.heartRateUnit)
                    self.lblHeartRate.setText(String("Heart Rate: \(hRate)"))
                    print("HRate is =\(hRate)")
                    if hRate >= 60.0 {
                        self.sendNotification()
                    }
                }
            }
        }
        return query
    }
    
    
    func sendNotification() {
        // 1
        let content = UNMutableNotificationContent()
        content.title = "Heart Rate increasing above 60"
        content.subtitle = ""
        content.body = "Take Rest"
        
        // 2
//        let imageName = "user"
//        guard let imageURL = Bundle.main.url(forResource: imageName, withExtension: "png") else { return }
//
//        let attachment = try! UNNotificationAttachment(identifier: "apptest", url: imageURL, options: .none)
//
//        content.attachments = [attachment]
        
        // 3
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "notification.id.01", content: content, trigger: trigger)
        
        // 4
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
  
}
