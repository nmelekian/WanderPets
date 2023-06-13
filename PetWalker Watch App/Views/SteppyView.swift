//
//  CreatureAnimationView.swift
//  PetWalker Watch App
//
//  Created by Anahita Zahertar on 5/24/23.
//

import Foundation
import SwiftUI

struct SteppyView: View {
    //Global play animation boolean
    @AppStorage("play_animation") var playAnimation: Bool = true
    // Local play animation boolean
    @State var animations_playing: Bool = false
    
    // Choose which animation to play:
    // Empty : basic moves
    // dance : Hawaiian dance
    // butt : well... butt!
    // cracked_egg_open : when the egg is cracked open, and the top shell is moving
    var animation_to_play: String = ""
    
    // Name of the images to use for each part
    // For the booleans "has_...", is used to display or not the corresponding part
    var img_head = "egg"
    var img_arm_left = "arm_left"
    var img_arm_right = "arm_right"
    
    var has_antennas = false
    var img_antenna_left = "antenna"
    var img_antenna_right = "antenna"
    
    var has_body = false
    var img_body = "body"
    
    var has_butt = false
    var img_butt = "skirt"
    
    var has_legs = false
    var img_legs = "legs"
    
    
    // # Animation controls #
    // Antennas
    @State var animate_antenna: Bool = false
    let animation_antenna: Animation = Animation.linear(duration: 2.0).repeatForever(autoreverses: true)
    
    
    // Arms
    @State var animate_arm: Bool = false
    let animation_arm: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: true)
    
    @State var animate_arm_dance: Bool = false
    let animation_arm_dance: Animation = Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
    
    
    // Skirt
    @State var animate_skirt: Bool = false
    let animation_skirt: Animation = Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
    
    // Butt
    @State var animate_BUTT: Bool = false
    let animation_BUTT: Animation = Animation.linear(duration: 0.15).repeatForever(autoreverses: true) // Change the butt speed here
    
    
    // Head
    @State var animate_head: Bool = false
    let animation_head: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: true)
    
    // Egg (The head without legs, or head with legs but no body)
    @State var animate_egg: Bool = false
    let animation_egg: Animation = Animation.linear(duration: 1).repeatForever(autoreverses: true)
    
    // Top shell
    @State var animate_top_shell: Bool = false
    let animation_top_shell: Animation = Animation.linear(duration: 0.5).repeatForever(autoreverses: true)
    
    //Variables to control the horizontal flip animation
    @State var animate_flip_horizontal: Bool = false
    @State var flipped_horizontal: Bool = false
    @State var flip_after_time = 3
    
    var body: some View {
        ZStack{
            
//            Rectangle()
//                .fill(Color.blue)
//                .frame(width: 300, height: 20)
//                .offset(y:150)
            
            // Legs group
            if has_legs || has_body {
                Image(img_legs)
                    .offset(y: has_body ? 100 : 100) // To correctly place the image, move down if there is a body
                    .offset(y: has_butt ? 20 : 0) // To correctly place the image, move downer if there is a BUTT
            }
            
            // Body group
            if has_body {
                ZStack{
                    Image(img_body)
                    
                    // Display the arms at different position and at different speed based on the required animatino
                    HStack(spacing: animation_to_play == "dance" ? 50 : 110){ // Reduce space between arms if it is the dance animation
                        if animation_to_play == "dance"{
                            // Display two left arms that rotate in different directions
                            Image("arm_left_outline")
                                .rotationEffect(.degrees( animate_arm_dance ? 30 : 10), anchor: .topLeading)
                                .animation(animate_arm_dance && playAnimation ? animation_arm_dance : .default, value: animate_arm_dance)
                            Image(img_arm_left)
                                .rotationEffect(.degrees( animate_arm_dance ? 10 : 30), anchor: .topLeading)
                                .animation(animate_arm_dance && playAnimation ? animation_arm_dance : .default, value: animate_arm_dance)
                            
                        }
                        else if animation_to_play == "wave" {
                            // Rotate the right arm at a faster pace and at a wider angle
                            Image(img_arm_right)
                                .rotationEffect(.degrees( animate_arm_dance ? 30 : -40), anchor: .topTrailing)
                                .animation(animate_arm_dance && playAnimation ? animation_arm_dance : .default, value: animate_arm_dance)
                            Image(img_arm_left)
                                .rotationEffect(.degrees( animate_arm ? 40 : 30), anchor: .topLeading)
                                .animation(animate_arm && playAnimation ? animation_arm : .default, value: animate_arm)
                        }
                        else {
                            Image(img_arm_right)
                                .rotationEffect(.degrees( -40), anchor: .topTrailing)
                                .offset(x: animate_arm ? -10 : 10)
                                .animation(animate_arm && playAnimation ? animation_arm : .default, value: animate_arm)
                            Image(img_arm_left)
                                .rotationEffect(.degrees(40), anchor: .topLeading)
                                .offset(x: animate_arm ? -10 : 10)
                                .animation(animate_arm && playAnimation ? animation_arm : .default, value: animate_arm)
                        }
                    }.offset(x: animation_to_play == "dance" ? 40 : 0, y:-30) // To correctly place the image if it is the dance animation, to have them centered to body
                    if has_butt {
                        if animation_to_play == "butt" {
                            Image(img_butt)
                                .scaleEffect(1.5)
                                .offset(y:40) // To correctly place the image
                                .offset(x: animate_BUTT ? -7 : 7)
                                .animation(animate_BUTT && playAnimation ? animation_BUTT : .default, value: animate_BUTT)
                        }
                        else {
                            Image(img_butt)
                                .offset(y:70) // To correctly place the image
                                .rotationEffect(.degrees( animate_skirt ? 5 : -5), anchor: .center)
                                .animation(animate_skirt && playAnimation ? animation_skirt : .default, value: animate_skirt)
                        }
                    }
                }
                .offset(y:20) // To correctly place the image, move the body up compared to center of screen
            }
            
            // Head group
            if animation_to_play == "cracked_egg_open" {
                // Change the behavior of the head if it is the cracked egg animation
                ZStack{
                    Image(img_head)
                    
                    // For cracked egg open animation, add the top of the cracked egg and make it rotating
                    Image("egg_cracked_top")
                        .offset(y: -95) // To correctly place the image
                        .rotationEffect(.degrees( animate_top_shell ? 0 : 12), anchor: .bottomTrailing)
                        .animation(animate_top_shell && playAnimation ? animation_top_shell : .default, value: animate_top_shell)
                }
                .offset(y: 30) // To correctly place the image, move the head if there are legs
                .rotationEffect(.degrees( animate_head ? 2 : -2), anchor: .bottom)
                .animation(animate_head && playAnimation ? animation_head : .default, value: animate_head)
                
            }
            else {
                // Head group
                ZStack{
                    Image(img_head)
                    if has_antennas {
                        HStack(spacing: 50){
                            Image(img_antenna_right)
                                .rotationEffect(.degrees( animate_antenna ? -10 : -30), anchor: .bottom)
                                .animation(animate_antenna && playAnimation ? animation_antenna : .default, value: animate_antenna)
                            Image(img_antenna_left)
                                .rotationEffect(.degrees( animate_antenna ? 28 : 40), anchor: .bottom)
                                .animation(animate_antenna && playAnimation ? animation_antenna : .default, value: animate_antenna)
                        }.offset(y: -110) // To correctly place the image
                    }
                }
                .offset(y: has_legs ? -10 : 40) // To correctly place the image, move the head if there are legs
                .offset(y: has_body ? -110 : 0) // To correctly place the image, move the head if there are legs
                .rotationEffect(.degrees( animate_head ? 2 : -2), anchor: .bottom)
                .rotationEffect(.degrees( (animate_egg && !has_legs) ? 10 : 00), anchor: .bottom)
                .rotationEffect(.degrees( (animate_egg && !has_body) ? 10 : has_body ? 0  : -10), anchor: .bottom)
                .animation(animate_egg && playAnimation ? animation_egg : .default, value: animate_egg)
                .animation(animate_head && playAnimation ? animation_head : .default, value: animate_head)
                
            }
        }
        
        .scaleEffect(CGSize(width: flipped_horizontal ? -1.0 : 1, height: 1))
        .scaleEffect(0.5) // Scale down the whole animation
        .onAppear {
            // If the "Play animation" settings has changed, then switch the animation to on/off depending on the previous state
            if animations_playing != playAnimation {
                animations_playing.toggle()
                
                animate_antenna.toggle()
                animate_arm.toggle()
                animate_arm_dance.toggle()
                animate_BUTT.toggle()
                animate_skirt.toggle()
                animate_head.toggle()
                animate_egg.toggle()
                animate_top_shell.toggle()
                
                if animation_to_play == "dance" {
                    animate_flip_horizontal.toggle()
                }
            }
            
            if animate_flip_horizontal {
                flip_horizontally()
            }
        }
    }
    
    
    
    
    
    //Flip Steppy horizontally
    private func flip_horizontally(){
        // If we still play the flip animation, make the flip after the time set in var flip_after_time
        if animate_flip_horizontal {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(flip_after_time)) {
                flipped_horizontal.toggle()
                flip_horizontally()
            }
        } else {
            flipped_horizontal = false // If we don't play the animation anymore, turn off the flip
        }
    }
    
    // Wait 4 seconds before flipping face again
    private func wait_next_flip(){
        let seconds = 4.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            flip_horizontally()
        }
    }
    
}

struct SteppyView_Previews: PreviewProvider {
    static var previews: some View {
        SteppyView()
        SteppyAnimation.egg.view
        SteppyAnimation.egg_legs.view
        SteppyAnimation.cracked_egg.view
        SteppyAnimation.small.view
        SteppyAnimation.tall.view
        SteppyAnimation.waving.view
        SteppyAnimation.dancing.view
        SteppyAnimation.butt.view
    }
}




// Options to select and render the correct animation
enum SteppyAnimation {
    case egg
    case egg_legs
    case cracked_egg
    case small
    case tall
    case waving
    case dancing
    case butt
    @ViewBuilder
    var view: some View {
        switch self {
        case .egg:
            SteppyView()
        case .egg_legs:
            SteppyView(img_head: "egg_w_crack", has_legs: true, img_legs: "legs")
        case .cracked_egg:
            SteppyView(animation_to_play: "cracked_egg_open", img_head: "egg_cracked_open", has_legs: true, img_legs: "legs")
        case .small:
            SteppyView(img_head: "head_face_closed_v2", has_legs: true, img_legs: "legs")
        case .tall:
            SteppyView(img_head: "head_face_normal_v2", has_body: true, img_body: "body", has_legs: true, img_legs: "legs")
        case .waving:
            SteppyView(animation_to_play: "wave", img_head: "head_face_closed_v2", has_antennas: true, has_body: true, img_body: "body", has_legs: true, img_legs: "legs")
        case .dancing:
            SteppyView(animation_to_play: "dance", img_head: "head_face_closed_v2", has_antennas: true, has_body: true, img_body: "body_coconut", has_butt: true, img_butt: "skirt", has_legs: true, img_legs: "legs")
        case .butt:
            SteppyView(animation_to_play: "butt", img_head: "head_shape", has_antennas: true, has_body: true, img_body: "body", has_butt: true, img_butt: "BUTT_v2", has_legs: true, img_legs: "legs_back")
        }
    }
}
