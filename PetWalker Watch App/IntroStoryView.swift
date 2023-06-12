//
//  IntroStoryView.swift
//  PetWalker Watch App
//
//  Created by Shannon Lane on 6/12/23.
//

import SwiftUI

struct IntroStoryView: View {
    @EnvironmentObject var vm: HealthKitViewModel
    @State private var move = false
    
    var body: some View {
        ScrollView {
            VStack {
                Image("longstory")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea(edges: .all)
                
                Button(action: {
                    vm.hasSeenIntro = true
                }, label: {
                    Text("Next")
                    
                })
                .background(Color.orange)
                .cornerRadius(25)
                
            }
        }
    }
}

struct IntroStoryView_Previews: PreviewProvider {
    static var previews: some View {
        IntroStoryView()
            .environmentObject(HealthKitViewModel())
    }
}