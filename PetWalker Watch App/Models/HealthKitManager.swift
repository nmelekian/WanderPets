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
    
    @Published var userStepCountToday = ""
    @Published var userStepCount = 0
    @Published var userDistance = ""
    @Published var userWheelchairDistance = ""
    @Published var isAuthorizedSteps = false
    @Published var isAuthorizedDistance = false
    @Published var isAuthorizedWheelchair = false
    @AppStorage("total_distance") var totalDistance: Double = 0.0
    @AppStorage("step_goal") var userStepGoal = 0
    @AppStorage("is_authorized") var isAuthorized = false
    
    
    /// Play animation boolean
    @AppStorage("play_animation") var playAnimation: Bool = true
    /// The user level
    @AppStorage("user_level") var userLevel: Int = 0
    /// The date when the user leveled up for last time
    @AppStorage("user_level_date") var userLevelDate: Double = Date().timeIntervalSinceReferenceDate
    
    /// Dictionary where key = level, value = nb of days to reach the level
    let days_required_levelup = [0:1,
                                 1:1,
                                 2:1,
                                 3:2,
                                 4:4,
                                 5:8,
                                 6:16,
                                 7:32]
    /// Dictionary where key = level, value = animation to play
    let animation_level = [0: SteppyAnimation.egg,
                           1: SteppyAnimation.egg_legs,
                           2: SteppyAnimation.cracked_egg,
                           3: SteppyAnimation.small,
                           4: SteppyAnimation.tall,
                           5: SteppyAnimation.waving,
                           6: SteppyAnimation.dancing,
                           7: SteppyAnimation.butt]
    
    /// Check if the user has leveled up since last time they opened the app
    func checkLevelUp() {
        // Date of the day
        let today = Date()
        // Date when the user leveled up for last time
        let userLevelDate = Date(timeIntervalSinceReferenceDate: self.userLevelDate)
        // Count number of days that have the minimum amount of steps
        var countDaysValidated = 0
        // Calendar object to calculate the number of days
        let calendar = Calendar.current
        //Number of days that elapsed since the user leveled up
        let nbDaysElapsed = calendar.numberOfDaysBetween(userLevelDate, and: today)
        // If not enough days have passed to level up, return false
        if nbDaysElapsed < days_required_levelup[self.userLevel]! {
            return
        }
        
        // Calculate number of days with the right amount of steps
        for d in 0...nbDaysElapsed {
            let previous_date = today.addingTimeInterval(Double(-d * 86400)) // There are 86400 seconds in a day
            self.readStepsTaken(for: previous_date) // Calculate the number of steps taken for previous days
            if self.userStepCount >= self.userStepGoal { // If user has walked more than the set goal, we increment the number of days validated
                countDaysValidated += 1
            }
        }
        
        // If the user has validated enough days to level up, then increment level
        if countDaysValidated >= self.days_required_levelup[self.userLevel]!{
            print("User levels up! From level "+self.userLevel.description+" to level "+(self.userLevel + 1).description)
            self.userLevel = min( (self.userLevel + 1) ,7)
            self.userLevelDate = Date().timeIntervalSinceReferenceDate
            return
        }
        
        // If user hasn't validated enough days, return false and do nothing
        return
    }
    
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
        healthKitManager.readStepCount(for: Date(), healthStore: healthStore) {step in
            if step != 0.0 {
                DispatchQueue.main.async {
                    self.userStepCountToday = String(format: "%.0f", step)
                }
            }
        }
    }
    
    func readStepsTaken(for the_date: Date){
        healthKitManager.readStepCount(for: the_date, healthStore: healthStore) {step in
            if step != 0.0 {
                DispatchQueue.main.async {
                    self.userStepCount = Int(round(step))
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
    
    func readStepCount(for the_date: Date, healthStore: HKHealthStore, completion: @escaping (Double) -> Void) {
        guard let stepQuantityType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {return}
        
        let startOfDay = Calendar.current.startOfDay(for: the_date)
        
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: the_date, options: .strictStartDate)
        
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


// Add a new function to the calendar to calculate the number of days between two dates
extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int {
        let fromDate = startOfDay(for: from) // <1>
        let toDate = startOfDay(for: to) // <2>
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate) // <3>
        
        return numberOfDays.day!
    }
}
