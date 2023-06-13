//
//  SettingsView.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 6/8/2023.
//

import Foundation
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    
    let levels = 0...7

    var body: some View {
        NavigationView {
            Form {
                Toggle("Play animations", isOn: $vm.playAnimation)
                // Place other settings there in the future
                
                Picker("Level", selection: $vm.userLevel) {
                    ForEach(levels, id: \.self) {
                        Text($0.description)
                    }
                }
                Button {
                    vm.userLevel = 0
                    vm.userLevelDate = Date().timeIntervalSinceReferenceDate
                } label: {
                    Text("Reset User Data")
                }

            }
        }.navigationBarTitle(Text("Settings"))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
