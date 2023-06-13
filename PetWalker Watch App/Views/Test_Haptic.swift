//
//  Test_Haptic.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 5/24/23.
//

import Foundation
import SwiftUI

struct Test_Haptic: View {
    var body: some View {
        VStack{
            Button(action: {
                WKInterfaceDevice.current().play(WKHapticType(rawValue: 0)!)
            }) {
                Text("Notification Feedback")
            }
            
            Button(action: {
                WKInterfaceDevice.current().play(.click)
            }) {
                Text("Success Feedback")
            }
            
            Button(action: {
                WKInterfaceDevice.current().play(WKHapticType(rawValue: 4)!)
            }) {
                Text("Failure Feedback")
            }
        }
    }
}

struct Test_Haptic_Previews: PreviewProvider {
    static var previews: some View {
        Test_Haptic()
    }
}
