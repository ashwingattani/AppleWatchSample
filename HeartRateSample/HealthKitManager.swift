//
//  HealthKitManager.swift
//  HeartRateSample
//
//  Created by Ashwin Gattani on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitManager: NSObject {
    
    let healthKitStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
    var heartRateQuery:HKSampleQuery?
    
    func authorizeHealthKit() {
        
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        ]
        
        healthKitStore.requestAuthorization(toShare: healthKitTypes,
                                            read: healthKitTypes) { _, _ in
                                                self.getTodaysHeartRates()
        }
    }
    
    /*Method to get todays heart rate - this only reads data from health kit. */
    func getTodaysHeartRates()
    {
        //predicate
        let calendar = NSCalendar.current
        let startDate = Date.init(timeIntervalSince1970: 0)
        let components = calendar.dateComponents([.year,.month,.day], from: startDate)
//        guard let startDate:NSDate = calendar.dateComponents(components) else { return }
        let endDate:Date? = calendar.date(byAdding: components, to: startDate)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        //descriptor
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]
        
        self.heartRateQuery = HKSampleQuery.init(sampleType: heartRateType, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors) { (query, results, error) in
            guard error == nil else { print("error"); return }
            
            self.printHeartRateInfo(results)
            
            //            self.updateHistoryTableViewContent(results)
        }
        healthKitStore.execute(heartRateQuery!)
        
    }//eom
    
    /*used only for testing, prints heart rate info */
    private func printHeartRateInfo(_ results:[HKSample]?)
    {
        print(results)
        for item in results! {
            guard let currData:HKQuantitySample = item as? HKQuantitySample else { return }
            
            print("[\(item)]")
            print("Heart Rate: \(currData.quantity.doubleValue(for: heartRateUnit))")
            print("quantityType: \(currData.quantityType)")
            print("Start Date: \(currData.startDate)")
            print("End Date: \(currData.endDate)")
            print("Metadata: \(String(describing: currData.metadata))")
            print("UUID: \(currData.uuid)")
            print("Source: \(currData.sourceRevision)")
            print("Device: \(String(describing: currData.device))")
            print("---------------------------------\n")
        }//eofl
    }//eom
}
