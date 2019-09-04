//
//  HealthKitManager.swift
//  HeartRateSample
//
//  Created by Atinderpal Singh on 25/06/19.
//  Copyright © 2019 Protons. All rights reserved.
//

import Foundation
import HealthKit
import Foundation
import AVFoundation
import CoreAudio
import CoreGraphics

class HealthKitManager: NSObject {
   
    let healthKitStore: HKHealthStore = HKHealthStore()
    let heartRateUnit:HKUnit = HKUnit(from: "count/min")
    let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    // Noise Detection
    private var secondPerDecibelCheck = 0
    var recorder: AVAudioRecorder!
    var maxDecibelDegree: CGFloat = 180
    var minDecibelDegree: CGFloat = 0
    var decibelArray = [CGFloat]()
    
    func authorizeHealthKit() {
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!,
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        ]
        healthKitStore.requestAuthorization(toShare: healthKitTypes,
                                            read: healthKitTypes) { _, _ in
                                                self.getTodaysHeartRates()
                                                self.setUpNoiseDetectionConfiguration()

                                                
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
        
        let query = HKSampleQuery.init(sampleType: heartRateType, predicate: predicate, limit: 25, sortDescriptors: sortDescriptors) { (query, results, error) in
            guard error == nil else { print("error"); return }
            
            self.printHeartRateInfo(results)
            
        }
        healthKitStore.execute(query)
        
    }//eom
    
    /*used only for testing, prints heart rate info */
    private func printHeartRateInfo(_ results:[HKSample]?)
    {
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
        }
    }
    
    
    
//    func fetchHealthKitData() {
//        self.fetchHealthData { (query, samples, deletedObjects, anchor,
//            heartRateUnit, error) in
//        }
   // }
    
     func fetchHealthData(resultHandler: @escaping (SoundDetection,HealthKitDetection)->Void )
    {
        self.createStreamingQuery { (soundDetection, healthDetection) in
            resultHandler(soundDetection,healthDetection)
        }
    }
    
    private func createStreamingQuery(resultHandler: @escaping (SoundDetection,HealthKitDetection)->Void )
    {
        
        let queryPredicate = HKQuery.predicateForSamples(withStart: Date.distantPast, end: Date(), options: .strictEndDate)
        
        let query = HKAnchoredObjectQuery.init(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: Int(HKObjectQueryNoLimit)) { (query, samples, deletedObjects, anchor, error) in
            if let errorFound = error {
                print("query error: \(errorFound.localizedDescription)")
            } else {
              // let noiseDetection = self.detectNoiseAround()
              let noiseDetection = SoundDetection.init()

               let healthKitDetection = HealthKitDetection.init(query: query, samples: samples, deletedObjects: deletedObjects, anchor: anchor, heartRateUnit: self.heartRateUnit, error: error)
                resultHandler(noiseDetection,healthKitDetection)
                return
            }
        }
        healthKitStore.execute(query)

    }
    
    func setUpNoiseDetectionConfiguration()  {
        self.secondPerDecibelCheck = 50
        do{
            let audioSession:AVAudioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            let documents: AnyObject = NSSearchPathForDirectoriesInDomains(
                FileManager.SearchPathDirectory.documentDirectory,
                FileManager.SearchPathDomainMask.userDomainMask,
                true
                )[0] as AnyObject
            
            let cafPath: String = "recordTest.caf"
            let str : String =  documents.appendingPathComponent(cafPath)
            let url = NSURL.fileURL(withPath: str)
            
            let recordSettings: [NSObject : AnyObject] =
                [
                    AVFormatIDKey as NSObject:kAudioFormatAppleIMA4 as AnyObject,
                    AVSampleRateKey as NSObject:44100 as AnyObject,
                    AVNumberOfChannelsKey as NSObject:1 as AnyObject,
                    AVLinearPCMBitDepthKey as NSObject:16 as AnyObject,
                    AVLinearPCMIsBigEndianKey as NSObject:false as AnyObject,
                    AVLinearPCMIsFloatKey as NSObject:false as AnyObject
            ]
            print(url)
           
            self.recorder = try AVAudioRecorder(url:url, settings: recordSettings as! [String : AnyObject])
            self.recorder.prepareToRecord()
            self.recorder.isMeteringEnabled = true
            self.recorder.record()
            self.detectNoiseAround()
            
        }catch let e{
                print("Error Desc ----")
                print(e.localizedDescription)
        }
    }
    
     func detectNoiseAround() -> SoundDetection {
        recorder.updateMeters()
        var level : CGFloat!
        let minDecibels: CGFloat = -80
        let decibels = recorder.averagePower(forChannel: 0)
        if decibels < Float(minDecibels)
        {
            level = 0
        }
        else if decibels >= 0
        {
            level = 1
        }
        else
        {
            let root: Float = 2
            let minAmp = powf(10, 0.05 * Float(minDecibels))
            let inverseAmpRange: Float = 1 / (1 - minAmp)
            let amp = powf(10, 0.05 * decibels)
            let adjAmp: Float = (amp - minAmp) * inverseAmpRange
            level = CGFloat(powf(adjAmp, 1/root))
        }
        level = level * self.maxDecibelDegree + self.minDecibelDegree
        let degree: CGFloat = level/(self.maxDecibelDegree - self.minDecibelDegree)
        let radian: CGFloat = level*CGFloat(M_PI)/180
        
        if self.decibelArray.count >= self.secondPerDecibelCheck
        {
            _ = self.decibelArray.removeFirst()
        }
        self.decibelArray.append(level)
      //  return SoundDetection(level: level, average: self.decibelArray.average, degree: degree, radian: radian)
        return SoundDetection.init()
    }
    
}

extension Array where Element: FloatingPoint {
    fileprivate var total: Element {
        return reduce(0, +)
    }
    fileprivate var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

struct SoundDetection {
    var level : CGFloat
    var average : CGFloat
    var degree : CGFloat
    var radian : CGFloat
    
    init() {
        self.level   = 0.0
        self.average = 0.0
        self.degree = 0.0
        self.radian = 0.0
    }
}

struct HealthKitDetection {
    var query : HKAnchoredObjectQuery
    var samples : [HKSample]?
    var deletedObjects : [HKDeletedObject]?
    var anchor : HKQueryAnchor?
    var heartRateUnit : HKUnit
    var error : Error?
}

struct HealthDataResponseVo {
    var soundDetection : SoundDetection
    var healthKitDetection : HealthKitDetection
}
