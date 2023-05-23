//
//  PetWalkerApp.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/8/23.
//

import SwiftUI

@main
struct PetWalker_Watch_AppApp: App {
    var viewModel = HealthKitViewModel()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
