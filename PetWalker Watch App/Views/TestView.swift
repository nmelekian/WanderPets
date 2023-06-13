//
//  TestView.swift
//  PetWalker Watch App
//
//  Created by Nicholas Melekian on 5/11/23.
//

import SwiftUI

struct TestView: View {
    @State var toggleSheet = false
    var body: some View {
        CircularProgressView(toggleSheet: $toggleSheet, progress: 0.5, progress2: 0.7)
        Text("Hi")

    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
