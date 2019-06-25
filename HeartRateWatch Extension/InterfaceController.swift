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

class InterfaceController: WKInterfaceController {

    @IBOutlet weak var lblHeartRate: WKInterfaceLabel!
    
    let health: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    var heartRateQuery:HKQuery?
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        
        heartRateQuery = self.createStreamingQuery()
        health.execute(heartRateQuery!)
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
        let queryPredicate  = HKQuery.predicateForSamples(withStart: Date.init(timeIntervalSince1970: 0), end: nil, options: [])
        let query = HKAnchoredObjectQuery.init(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: 25) { (query, samples, deletedObjects, anchor, error) in
            if let errorFound = error {
                print("query error: \(errorFound.localizedDescription)")
            } else {
                //printing heart rate
                if let fetchedSamples = samples as? [HKQuantitySample]
                {
                    for item in fetchedSamples {
                        print("Heart Rate: \(item.quantity.doubleValue(for: self.heartRateUnit))")
                    }
                }
            }
        }//eo-query
        
//        query.updateHandler =
//            { (query:HKAnchoredObjectQuery, samples:[HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:NSError?) -> Void in
//
//                if let errorFound:NSError = error
//                {
//                    print("query-handler error : \(errorFound.localizedDescription)")
//                }
//                else
//                {
//                    //printing heart rate
//                    if let samples = samples as? [HKQuantitySample]
//                    {
//                        if let quantity = samples.last?.quantity
//                        {
//                            print("\(quantity.doubleValue(for: self.heartRateUnit))")
//                        }
//                    }
//                }//eo-non_error
//            }//eo-query-handler
        
        return query
    }

}
