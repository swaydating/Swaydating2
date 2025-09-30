//
//  ContentView.swift
//  Sway
//
//  Created by Lawrence Jones on 6/8/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        SwayAuthView()
            .preferredColorScheme(.dark)
            .background(Color.black.ignoresSafeArea())
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().previewDevice("iPhone 15 Pro")
    }
}