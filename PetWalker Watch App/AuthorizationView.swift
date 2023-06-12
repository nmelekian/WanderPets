//
//  AuthorizationView.swift
//  PetWalker Watch App
//
//  Created by Shannon Lane on 6/8/23.
//

import SwiftUI

struct AuthorizationView: View {
    
    @EnvironmentObject var vm: HealthKitViewModel
    
    var body: some View {
        VStack{
            
            Button {
                vm.healthRequest()
                vm.isAuthorized.toggle()
                
                
            } label: {
                Text("Authorize HealthKit")
                    .font(.body)
                    .foregroundColor(.white)
            }
            .background(Color(.orange))
            .cornerRadius(25)
        }
    }
    
}

struct AuthorizationView_Previews: PreviewProvider {
    static var previews: some View {
        AuthorizationView()
            .environmentObject(HealthKitViewModel())
    }
}
