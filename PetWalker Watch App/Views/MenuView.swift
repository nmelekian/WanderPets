//
//  MenuView.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 6/8/2023.
//

import Foundation
import SwiftUI

struct MenuView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    
    var body: some View {
        List{
            NavigationLink{
                ProfileView().environmentObject(vm)
            } label: {Text("Profile")}
            NavigationLink{
                SettingsView().environmentObject(vm)
            } label: {Text("Settings")}
        }
        
    }
}


struct MenuView_Previews: PreviewProvider {
    static let vm = HealthKitViewModel()
    
    static var previews: some View {
        MenuView()
            .environmentObject(vm)
    }
}
