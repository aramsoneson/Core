//
//  WelcomeView.swift
//  Core
//
//  Created by Aram Soneson on 2/24/25.
//

import SwiftUI
import LaunchAtLogin

struct WelcomeView: View {
    // Defines the variable for whether the Welcome window opens
    @AppStorage("shouldWelcome") var shouldWelcome: Bool = true

    var body: some View {
        VStack {
            // Creates a group of elements that will be placed on top of each other
            ZStack {
                // Adds the image that creates the glow effect
                Image("Icon")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(0.5)
                // Adds the main detailed image
                Image("Icon")
                    .resizable()
                    .frame(width: 140, height: 140)
                    .shadow(radius: 4, y: 2)
            }
            .padding(.bottom, 10)
            
            // Groups the welcome text and app title
            VStack {
                Text("Welcome to")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
                Text("Core")
                    .font(.system(size: 48, weight: .black))
                    .fontWidth(.expanded)
            }
            // Adds spacing to the bottom
            .padding(.bottom, 15)

            // Groups the descriptive text and toggle together
            VStack {
                Text("Launch at login")
                // Creates a toggle for whether the app opens when logging in
                LaunchAtLogin.Toggle("")
                    .toggleStyle(.switch)
                    .controlSize(.small)
            }
            // Adds spacing to the bottom
            .padding(.bottom, 15)

            // Adds the button to move to the next page
            Button {
                NSApp.keyWindow?.close()
            } label: {
                Text("Get Started")
                    // Makes the button wider
                    .padding(.horizontal, 20)
            }
            // Makes the button larger
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        // Moves the entire VStack up 20 to make it more visually centered
        .padding(.top, -20)
    }
}

#Preview {
    WelcomeView()
        // Removes the window toolbar's title text
        .toolbar(removing: .title)
    
        // Sets the window's width and height
        .frame(width: 420, height: 480)
}
