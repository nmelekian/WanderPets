//
//  ProfileView.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 6/8/2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    
    var body: some View {
        List{
            Text("Your level: " + vm.userLevel.description)
//            Text("Level date: " + vm.userLevelDate.description) // For test only
            Text("Today's steps: " + vm.userStepCountToday)
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static let viewModel = HealthKitViewModel()
    
    static var previews: some View {
        ProfileView()
            .environmentObject(viewModel)
    }
}
