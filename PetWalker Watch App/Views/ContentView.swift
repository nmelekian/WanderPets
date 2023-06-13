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
    
    // Variables to update playing animation in the view
    @State var steppy = 0
    @State var playAnim: Bool = true
    // Transition animation
    let animation_Move_Steppy_Out_In: Animation = Animation.linear(duration: 1)
    @State var move_Steppy_out: Bool = false
    @State var move_Steppy_in: Bool = false
    
    var body: some View {
        
        NavigationStack {
            ZStack {
                Image("background 1")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .all)
                
                VStack {
                    if vm.isAuthorized {
                        Group{
                            VStack{
                                Spacer()
                                vm.animation_level[steppy]?.view
                                    .frame(width: 80, height: 80) // Modify this frame size in order to indicate to the other elements on the page the space that is reserved for your animation
                                    .scaleEffect(0.6) // After modifying the frame, modify this scale ratio to make the animation the size you want
                                    .offset(x: move_Steppy_out ? 200 : 0, y: move_Steppy_out ? -200 : 0)
                                    .rotationEffect(.degrees(move_Steppy_out ? 45 : 0))
                                    .offset(x: move_Steppy_in ? -200 : 0, y: move_Steppy_in ? -200 : 0)
                                    .rotationEffect(.degrees(move_Steppy_in ? -45 : 0))
                                
                                HStack {
                                    // Display a settings icon that shows the menu
                                    NavigationLink{
                                        MenuView().environmentObject(vm)
                                    }label: {Image("settings")}.frame(width: 60)
                                    
                                    Spacer()
                                                                
                                    CircularProgressView(toggleSheet: $toggleSheet, progress: (Double(vm.userStepCountToday) ?? 0.0)/Double(vm.userStepGoal), progress2: (Double(vm.userDistance) ?? 0)/10)
                                    
                                }
                                
                            }
                        }
                    } else {
                        VStack {
                            
                            Button {
                                vm.healthRequest()
                                vm.isAuthorized.toggle()
                                
                                
                            } label: {
                                Text("Authorize HealthKit")
                                    .font(.body)
                                    .foregroundColor(.white)
                            }
                           // .frame(width: 200, height: 55)
                            .background(Color(.orange))
                            .cornerRadius(25)
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
                    
                    setPlayReminder()
                    
                    // Check if the animation should play
                    playAnim = vm.playAnimation
                    
                    // Check if user has leveled up
                    vm.checkLevelUp()
                    
                    // If user has leveled up, make a transition to change Steppy animation
                    if steppy != vm.userLevel {
                        if playAnim{
                            withAnimation(animation_Move_Steppy_Out_In) {
                                move_Steppy_out.toggle()
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                steppy = vm.userLevel
                                move_Steppy_out.toggle()
                                move_Steppy_in.toggle()
                                withAnimation(animation_Move_Steppy_Out_In) {
                                    move_Steppy_in.toggle()
                                }
                            }
                        }
                        else {
                            steppy = vm.userLevel
                        }
                    }
                }
            }.navigationTitle(Text("\(vm.userStepCountToday) steps"))
                .navigationBarTitleDisplayMode(.inline)

           
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
