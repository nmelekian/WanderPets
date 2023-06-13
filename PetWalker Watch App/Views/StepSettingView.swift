//
//  StepSettingView.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/11/23.
//

import SwiftUI

struct StepSettingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var stepGoal: Int
    let stepSelections = [2000,2500,3000,3500,4000,4500,5000,5500,6000,6500,7000,7500,8000,8500,9000,9500,10000,10500,11000,11500,12000,12500,13000,13500,14000,14500,15000]
    var body: some View {
        VStack{
            Text("Set Step Goal:")
            Picker("Steps", selection: $stepGoal) {
                ForEach(stepSelections, id: \.self) {
                    Text("\($0)")
                }
            }
            Button {
                
                dismiss()
            } label: {
                Text("Set Goal")
            }
        }
    }
}

//struct StepSettingView_Previews: PreviewProvider {
//    static var previews: some View {
//        StepSettingView(stepGoal: 100)
//    }
//}
