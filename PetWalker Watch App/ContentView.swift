//
//  ContentView.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/8/23.
//

import SwiftUI
import HealthKit
import UserNotifications

struct ContentView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    @State private var toggleSheet = false
    @State private var petToggle = false
    @State private var isTapped = false
    
    
    var body: some View {
        
        
        VStack {
            if vm.isAuthorized {
                VStack{
                    if isTapped {
                        CreatureAnimationView(animation_to_play: "cracked_egg") // Modify the "animation_to_play" value to call the animation you want
                            .frame(width: 80, height: 80) // Modify this frame size in order to indicate to the other elements on the page the space that is reserved for your animation
                            .scaleEffect(0.5) // After modifying the frame, modify this scale ratio to make the animation the size you want
                            .onTapGesture {
                                isTapped.toggle()
                            }
                    } else {
                        
                        VStack{
                            ZStack{
                                // Cracked Egg
                                Image("cracked_bottom_w_legs")
                                    .scaleEffect(0.5)// Have to put a scaleEffect as original image is too big
                                    .offset(y:60)
                                // Top Cracked Egg
                                Image("top_shell")
                                    .scaleEffect(0.22)// Have to put a scaleEffect as original image is too big
                                
                                    .frame(width: 100, height: 100) // Have to put a frame as original image is too big
                                    .offset(y:-37)
                            }
                            .scaleEffect(0.7)
                        }
                        .frame(width: 80, height: 80) // Modify this frame size in order to indicate to the other elements on the page the space that is reserved for your animation
                        .scaleEffect(0.5) // After modifying the frame, modify this scale ratio to make the animation the size you want
                        .onTapGesture {
                            isTapped.toggle()
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    VStack{
                        Text("Today's Step Count")
                            .font(.title3)
                        HStack{
                            VStack{
                                Text("\(vm.userStepCount) steps")
                                Text("\(String(format: "%.2f", vm.totalDistance)) miles")
                            }
                            CircularProgressView(toggleSheet: $toggleSheet, progress: (Double(vm.userStepCount) ?? 0.0)/Double(vm.userStepGoal), progress2: (Double(vm.userDistance) ?? 0)/10)

                        }
                    }
                    
                    
                    
//                    HStack{
//
//
//
//                        Image(petToggle == true ? "happy": "chillin" )
//                            .onTapGesture {
//                                petToggle.toggle()
//                            }
//
//                    }
//                    VStack{
//                        Text("Today's Step Count")
//                            .font(.title3)
//                        HStack{
//                            VStack{
//                                Text("\(vm.userStepCount) steps")
//                                Text("\(vm.userDistance) miles")
//                            }
//                            CircularProgressView(toggleSheet: $toggleSheet, progress: (Double(vm.userStepCount) ?? 0.0)/Double(vm.userStepGoal), progress2: (Double(vm.userDistance) ?? 0)/10)
//
//                        }
//                    }
                }
            } else {
                VStack {
                    Text("Please Authorize Health!")
                        .font(.title3)

                    Button {
                        vm.healthRequest()
                        setPlayReminder()
                        vm.isAuthorized.toggle()


                    } label: {
                        Text("Authorize HealthKit")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .frame(width: 320, height: 55)
                    .background(Color(.orange))
                    .cornerRadius(10)
                }
            }
        }
        .sheet(isPresented: $toggleSheet, content: {
            StepSettingView(stepGoal: $vm.userStepGoal)
        })
        .padding()
        .onAppear {
            vm.readStepsTakenToday()
            vm.readDistanceToday()
            vm.testCollectionQuery()
            
            
        }
    }
    
    // Creates notification content and schedules the notification
    func createNotification() {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = "Blobby misses you!"
        // note: this can add a custom sound
        content.body = "Help Blobby get his steps in."
        content.sound = .default
        content.categoryIdentifier = "play_reminder"
        
        // this is a test trigger using a short time interval:
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 61, repeats: true)
        
        
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
    }
    
    func setPlayReminder() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                center.removeAllPendingNotificationRequests()
                registerCategories()
                createNotification()
            }
        }
    }
    
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        
        let play = UNNotificationAction(identifier: "Play", title: "Play Now", options: .foreground)
        let category = UNNotificationCategory(identifier: "play_reminder", actions: [play], intentIdentifiers: [])
        
        center.setNotificationCategories([category])
    }
    
    
    
    
    
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(HealthKitViewModel())
    }
}
