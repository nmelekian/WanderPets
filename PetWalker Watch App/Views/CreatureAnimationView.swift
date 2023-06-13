//
//  CreatureAnimationView.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 5/24/23.
//

import Foundation
import SwiftUI

struct CreatureAnimationView: View {
    var animation_to_play: String
    
    //Variables to control the arms and antennas animations on the butt and face animations
    @State var animate_arm: Bool = false
    @State var animate_antenna: Bool = false
    let animation_arm: Animation = Animation.linear(duration: 1.0).repeatForever(autoreverses: true)
    let animation_antenna: Animation = Animation.linear(duration: 2.0).repeatForever(autoreverses: true)
    
    
    //Variables to control the butt on the butt animation
    @State var animate_BUTT: Bool = false
    let animation_BUTT: Animation = Animation.linear(duration: 0.2).repeatForever(autoreverses: true) // Change the butt speed here
    
    //Variables to control the transition from butt to face on the butt animation
    @State var flip_after_time = 5
    @State var show_butt: Bool = false
    @State var show_butt_in: Bool = false
    let animation_show_butt: Animation = Animation.linear(duration: 0.5) // Change the butt speed here
    
    @State var show_face: Bool = true
    let animation_show_face: Animation = Animation.linear(duration: 0.5) // Change the butt speed here
    
    
    
    //Variables to control the egg and the top of the cracked egg on the egg and cracked egg animations
    @State var animate_egg: Bool = false
    let animation_egg: Animation = Animation.linear(duration: 0.5).repeatForever(autoreverses: true) // Change the butt speed here
    
    var body: some View {
        ZStack{
            if animation_to_play == "butt"{
                // Butt shaking
                ZStack{
                    // Arms
                    Image("arms").offset(x: animate_arm ? -5: 5)
                    // Antennas
                    Image("antenna").offset(x: animate_antenna ? -5: 5)
                    // Whole body
                    Image("back_body").scaleEffect(0.52).offset(x:-2,y:20)
                    // BUTT
                    Image("BUTTt").offset(x: animate_BUTT ? -2: 2)
                }
                .scaleEffect(0.7) // Applied a scale effect so it can be fully seen on the screen (else upper bar to go back would be over it)
//                .rotationEffect(.degrees(show_butt ? 0 : 90), anchor:  .bottomTrailing)
//                .offset(x: show_butt ? 0: -150,
//                        y: show_butt ? 0: -150)
            }
            else if animation_to_play == "face" {
                // Face forwarding
                ZStack{
                    // Arms
                    Image("arms").offset(x: animate_arm ? -5: 5)
                    // Antennas
                    Image("antenna").offset(x: animate_antenna ? -5: 5)
                    // Whole body
                    Image("whole_body")
                }
                .scaleEffect(0.7) // Applied a scale effect so it can be fully seen on the screen (else upper bar to go back would be over it)
//                .rotationEffect(.degrees(show_face ? 0 : 90), anchor:  .bottomTrailing)
//                .offset(x: show_face ? 0: -150,
//                        y: show_face ? 0: -150)
            }
            else if animation_to_play == "small" {
                // Small Egg head with legs
                ZStack{
                    // Legs
                    Image("legs_forward")
                        .scaleEffect(0.7)// Have to put a scaleEffect as original image is too big
                    // Head
                    Image("head_small_egg")
                        .scaleEffect(0.8)// Have to put a scaleEffect as original image is too big
                        .rotationEffect(.degrees(animate_egg ? 10 : -10), anchor: .bottom)
                }
                .scaleEffect(0.7) // Applied a scale effect so it can be fully seen on the screen (else upper bar to go back would be over it)
                
            }
            else if animation_to_play == "cracked_egg" {
                // Cracked Egg
                ZStack{
                    // Cracked Egg
                    Image("cracked_bottom_w_legs")
                        .scaleEffect(0.5)// Have to put a scaleEffect as original image is too big
                        .offset(y:60)
                    // Top Cracked Egg
                    Image("top_shell")
                        .scaleEffect(0.22)// Have to put a scaleEffect as original image is too big
                    
                        .frame(width: 100, height: 100) // Have to put a frame as original image is too big
                        .offset(y:-37)
                        .rotationEffect(.degrees(animate_egg ? 20 : 0), anchor: .bottomTrailing)
                }
                .scaleEffect(0.7) // Applied a scale effect so it can be fully seen on the screen (else upper bar to go back would be over it)
                
            }
            else if animation_to_play == "egg" {
                // Egg
                ZStack{
                    // Egg
                    Image("shell")
                        .scaleEffect(0.2)// Have to put a scaleEffect as original image is too big
                        .frame(width: 100, height: 100) // Have to put a frame as original image is too big
                        .rotationEffect(.degrees(animate_egg ? 20 : 0), anchor: .bottom)
                }
                .scaleEffect(0.7) // Applied a scale effect so it can be fully seen on the screen (else upper bar to go back would be over it)
                
            }
        }
        .onAppear {
            withAnimation(animation_antenna) {
                animate_antenna.toggle()
            }
            withAnimation(animation_arm) {
                animate_arm.toggle()
            }
            withAnimation(animation_BUTT) {
                animate_BUTT.toggle()
            }
            withAnimation(animation_show_butt) {
                show_butt.toggle()
            }
            withAnimation(animation_egg) {
                animate_egg.toggle()
            }
//            flip_face()
        }
    }
    
    //Flip from face to butt, based on what is currently shown
    private func flip_face(){
        let seconds = 0.5
        // If face shown, we flip it and send an async task to flip the butt once the face is not visible anymore
        if show_face {
            withAnimation(animation_show_face) {
                show_face.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                withAnimation(animation_show_butt) {
                    show_butt.toggle()
                }
                wait_next_flip()
            }
        }
        // If butt shown, we flip it and send an async task to flip the face once the butt is not visible anymore
        else {
            withAnimation(animation_show_butt) {
                show_butt.toggle()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                withAnimation(animation_show_face) {
                    show_face.toggle()
                }
                wait_next_flip()
            }
        }
    }
    
    // Wait 4 seconds before flipping face again
    private func wait_next_flip(){
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            flip_face()
        }
    }
}

struct CreatureAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        CreatureAnimationView(animation_to_play: "butt")
    }
}
