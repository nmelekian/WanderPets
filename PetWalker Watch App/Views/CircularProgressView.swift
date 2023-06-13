//
//  CircularProgressView.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/11/23.
//

import SwiftUI

struct CircularProgressView: View {
    @Binding var toggleSheet: Bool
    let progress: Double
    let progress2: Double
    var body: some View {
        ZStack{
            ZStack{
                Circle()
                    .stroke(
                        Color.green.opacity(0.5),
                        lineWidth: 5
                    )
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
            } .frame(width: 40, height: 40)
            
            ZStack{
                Circle()
                    .stroke(
                        Color.blue.opacity(0.5),
                        lineWidth: 5
                    )
                Circle()
                    .trim(from: 0, to: progress2)
                    .stroke(
                        Color.blue,
                        style: StrokeStyle(
                        lineWidth: 5,
                        lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
            } .frame(width: 30, height: 30)
            
            
//            ZStack{
//                Rectangle()
//                    .foregroundColor(.white)
//                Rectangle()
//                    .foregroundColor(.yellow)
//                    .frame(height: 20)
//            }
//            .frame(width: 5 , height: 5)
//            .mask {
                Image(systemName: "star.fill")
                .font(.caption)
//            }
         
                
                   

            
            
            
            
        }
        .onTapGesture {
            toggleSheet.toggle()
        }
    }
}

//struct CircularProgressView_Previews: PreviewProvider {
//    static var previews: some View {
//        CircularProgressView(toggleSheet: false, progress: 0.5, progress2: 0.75)
//    }
//}
