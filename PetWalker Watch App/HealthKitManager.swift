//
//  HealthKitManager.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/8/23.
//

import Foundation
import HealthKit
import SwiftUI



class HealthKitViewModel: ObservableObject {
     var healthStore = HKHealthStore()
    private var healthKitManager = HealthKitManager()
    
    @Published var userStepCount = ""
    @Published var userDistance = ""
    @Published var userWheelchairDistance = ""
    @Published var isAuthorizedSteps = false
    @Published var isAuthorizedDistance = false
    @Published var isAuthorizedWheelchair = false
    @AppStorage("total_distance") var totalDistance: Double = 0.0
    @AppStorage("step_goal") var userStepGoal = 0
    @AppStorage("is_authorized") var isAuthorized = false
    @AppStorage("has_seen_intro") var hasSeenIntro = false 
    

    
    func healthRequest() {
        healthKitManager.setUpHealthRequest(healthStore: healthStore) {
            self.changeStepAuthorizationStatus()
            self.changeDistanceAuthorizationStatus()
            self.changeWheelchairDistanceAuthorizationStatus()
            self.readStepsTakenToday()
            self.readDistanceToday()
            self.readWheelchairDistanceToday()
            self.testCollectionQuery()
            
        }
    }
    
    func readStepsTakenToday() {
        healthKitManager.readStepCount(forToday: Date(), healthStore: healthStore) {step in
            if step != 0.0 {
                DispatchQueue.main.async {
                    self.userStepCount = String(format: "%.0f", step)
                }
            }
        }
    }
    
    func readDistanceToday() {
        healthKitManager.readDistance(forToday: Date(), healthStore: healthStore) {distance, error in
            if distance != 0.0 {
                DispatchQueue.main.async {
                    self.userDistance = String(format: "%.2f", distance ?? 0)
//                    self.userDistance = Double(distance ?? 0)
                }
            }
        }
    }
    
    func readWheelchairDistanceToday() {
        healthKitManager.readWheelchairDistance(forToday: Date(), healthStore: healthStore) {distance, error in
            if distance != 0.0 {
                DispatchQueue.main.async {
                    self.userDistance = String(format: "%.2f", distance ?? 0)
//                    self.userDistance = Double(distance ?? 0)
                }
            }
        }
    }
    
    func testCollectionQuery() {
        healthKitManager.testCollectionQuery(healthStore: healthStore) {distance, error in
            if distance != 0.0 {
                DispatchQueue.main.async {
                    self.totalDistance = distance?.rounded() ?? 0
//                    self.userDistance = Double(distance ?? 0)
                }
            }
        }
    }
    
    
    
    
    
    func changeStepAuthorizationStatus() {
        guard let stepQtyType = HKObjectType.quantityType(forIdentifier: .stepCount) else {return}
        
        let status = self.healthStore.authorizationStatus(for: stepQtyType)
        
        
        switch status {
        case .notDetermined:
            isAuthorizedSteps = false
        case .sharingDenied:
            isAuthorizedSteps = false
        case .sharingAuthorized:
            isAuthorizedSteps = true
        @unknown default:
            isAuthorizedSteps = false
        }
        
        
    }
    
    func changeDistanceAuthorizationStatus() {
        guard let distanceQtyType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {return}
        let statusDist = self.healthStore.authorizationStatus(for: distanceQtyType)
        
        switch statusDist {
        case .notDetermined:
            isAuthorizedDistance = false
        case .sharingDenied:
            isAuthorizedDistance = false
        case .sharingAuthorized:
            isAuthorizedDistance = true
        @unknown default:
            isAuthorizedDistance = false
        }
    }
    
    func changeWheelchairDistanceAuthorizationStatus() {
        guard let distanceQtyType = HKObjectType.quantityType(forIdentifier: .distanceWheelchair) else {return}
        let statusDist = self.healthStore.authorizationStatus(for: distanceQtyType)
        
        switch statusDist {
        case .notDetermined:
            isAuthorizedDistance = false
        case .sharingDenied:
            isAuthorizedDistance = false
        case .sharingAuthorized:
            isAuthorizedDistance = true
        @unknown default:
            isAuthorizedDistance = false
        }
    }
    
}







class HealthKitManager {
    func setUpHealthRequest(healthStore: HKHealthStore, readSteps: @escaping () -> Void) {
        if HKHealthStore.isHealthDataAvailable(), let stepCount = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount), let distanceTotal = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning), let wheelchairDistance = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWheelchair)  {
            healthStore.requestAuthorization(toShare: [stepCount, distanceTotal, wheelchairDistance], read: [stepCount, distanceTotal, wheelchairDistance]) { success, error in
                if success {
                    readSteps()
                } else if error != nil {
                    print(error ?? "Error")
                }
            }
        }
        
    }
    
    func readStepCount(forToday: Date, healthStore: HKHealthStore, completion: @escaping (Double) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {return}
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) {_, result, error in
            
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0.0)
                return
            }
            
            completion(sum.doubleValue(for: HKUnit.count()))
            
        }
        
        healthStore.execute(query)
    }
    
    
    func readDistance(forToday: Date, healthStore: HKHealthStore, completion: @escaping (Double?, Error?) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {return}
        
        //        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            
            guard let result = result, error == nil else {
                completion(nil, error)
                return
            }
            
            let totalDistance = result.sumQuantity()?.doubleValue(for: .mile()) ?? 0
            
            completion(totalDistance, nil)
        }
        
        let healthStore = HKHealthStore()
        
        healthStore.execute(query)
       
    }
    
    func readWheelchairDistance(forToday: Date, healthStore: HKHealthStore, completion: @escaping (Double?, Error?) -> Void) {
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .distanceWheelchair) else {return}
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        
        let query = HKStatisticsQuery(quantityType: stepQuantityType, quantitySamplePredicate: predicate, options: .cumulativeSum) { (query, result, error) in
            
            guard let result = result, error == nil else {
                completion(nil, error)
                return
            }
            
            let totalDistance = result.sumQuantity()?.doubleValue(for: .mile()) ?? 0
            
            completion(totalDistance, nil)
        }
        
        let healthStore = HKHealthStore()
        
        healthStore.execute(query)
       
    }
    
    
    func testCollectionQuery(healthStore: HKHealthStore, completion: @escaping (Double?, Error?) -> Void) {
        let calendar = Calendar.current
        
        // create 1 week interval
        let interval = DateComponents(day: 7)
        var components = DateComponents(calendar: calendar,
                                        timeZone: calendar.timeZone,
                                        hour: 3,
                                        minute: 0,
                                        second: 0,
                                        weekday: 2)
        
        // set anchor for 3am on Monday
        guard let anchorDate = calendar.nextDate(after: Date(),
                                                 matching: components,
                                                 matchingPolicy: .nextTime,
                                                 repeatedTimePolicy: .first,
                                                 direction: .backward) else {
            fatalError("*** unable to find the previous Monday. ***")
        }
        
        guard let quantityType = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            fatalError("Unable to create a distance count type")
        }
        
        
        // create the query
        let query = HKStatisticsCollectionQuery(quantityType: quantityType,
                                                quantitySamplePredicate: nil,
                                                options: .cumulativeSum,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // set the results handler
        query.initialResultsHandler = {
            query, results, error in
            
            
        
        // Handle errors
            if let error = error as? HKError {
                switch (error.code) {
                case .errorDatabaseInaccessible:
                    return
                    
                default:
                    return
                }
            }
            
            guard let statsCollection = results else {
                // You should only hit this case if you have an unhandled error. Check for bugs in your code that creates the query or explicitly handle the error.
                assertionFailure("")
                return
            }
            
            
            let endDate = Date()
            let threeMonthsAgo = DateComponents(month: -3)
            
            var vm = HealthKitViewModel()
            
            guard let startDate = calendar.date(byAdding: threeMonthsAgo, to: endDate) else {
                fatalError("Unable to calculate start date")
            }
            
            statsCollection.enumerateStatistics(from: startDate, to: endDate) { (statistics, stop) in
                if let quantity = statistics.sumQuantity() {
                    let value = quantity.doubleValue(for: .mile())
                    
                    vm.totalDistance = value
                }
            }
        }
        
        healthStore.execute(query)
    }
    
    
    
}
