//
//  AboutView.swift
//  Core
//
//  Created by Aram Soneson on 2/21/25.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        // Creates a group elements that will be placed vertically
        VStack {
            // Creates a group of elements that will be placed on top of each other
            ZStack {
                // Adds the image that creates the glow effect
                Image("Icon")
                    .resizable()
                    .frame(width: 130, height: 130)
                    .blur(radius: 30)
                    .opacity(0.5)
                // Adds the main detailed image
                Image("Icon")
                    .resizable()
                    .frame(width: 130, height: 130)
                    .shadow(radius: 4, y: 2)
            }
            Text("Core")
                .font(.system(.largeTitle))
                .fontWidth(.expanded)
                .fontWeight(.black)
            Text("Version 1.0")
                .font(.system(.body))
        }
        // Moves the entire VStack up 20 to make it more visually centered
        .padding(.top, -20)
    }
}

#Preview {
    AboutView()
        // Removes the window toolbar's title text
        .toolbar(removing: .title)
    
        // Sets the window's width and height
        .frame(width: 250, height: 300)
}
