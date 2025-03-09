//
//  SettingsView.swift
//  Core
//
//  Created by Aram Soneson on 2/21/25.
//

import SwiftUI
import LaunchAtLogin

struct SettingsView: View {
    
    var body: some View {
        // Creates the tab layout
        TabView {
            // Creates the General tab
            Tab("General", systemImage: "gearshape") {
                // Links to the dedicated General view
                GeneralView()
            }
            // Creates the Advanced tab
            Tab("Advanced", systemImage: "wrench.and.screwdriver") {
                // Links to the dedicated Advanced view
                AdvancedView()
            }
        }
    }
}

// Defines the General settings view
struct GeneralView: View {
    // Defines the variable for the menu bar item's icon
    @AppStorage("menuBarIcon") private var menuBarIcon = "cpu"
    
    var body: some View {
        // Creates the visual structure of the settings options
        Form {
            // Creates a group of settings options
            Section {
                // Creates a toggle for whether the app opens when logging in
                LaunchAtLogin.Toggle("Launch at login")
                // Creates a dropdown menu with selectable items for the menu bar item's icons
                Picker("Menu bar icon", selection: $menuBarIcon) {
                    // Defines the available icons
                    // systemName defines how the option is shown in the window
                    // .tag defines what the variable will be set to
                    Text("    ")
                        .tag("    ")
                    Image(systemName: "cpu")
                        .tag("cpu")
                    Image(systemName: "cpu.fill")
                        .tag("cpu.fill")
                    
                    Image(systemName: "memorychip")
                        .tag("memorychip")
                    Image(systemName: "memorychip.fill")
                        .tag("memorychip.fill")
                    
                    Image(systemName: "gauge.with.needle")
                        .tag("gauge.with.needle")
                    Image(systemName: "gauge.with.needle.fill")
                        .tag("gauge.with.needle.fill")
                    
                    Image(systemName: "waveform")
                        .tag("waveform")
                    Image(systemName: "waveform.path")
                        .tag("waveform.path")
                }
            }
        }
        // Adds a background to the menu items to group them together
        .formStyle(.grouped)
    }
}

// Defines the Advanced settings view
struct AdvancedView: View {
    // Defines the variable for the number of decimal places the percentage goes out to
    @AppStorage("decimalPlaces") private var decimalPlaces: Int = 1
    
    var body: some View {
        // Creates the visual structure of the settings options
        Form {
            // Creates a group of settings options
            Section {
                // Creates a dropdown menu with selectable items for the number of percentage decimal places
                Picker("Percentage decimal places", selection: $decimalPlaces) {
                    // Defines the available decimal places
                    // First string defines how the option is shown in the window
                    // .tag defines what the variable will be set to
                    Text("0").tag(0)
                    Text("1").tag(1)
                    Text("2").tag(2)
                    Text("3").tag(3)
                    Text("4").tag(4)
                    Text("5").tag(5)
                    Text("6").tag(6)
                }
            }
        }
        // Adds a background to the menu items to group them together
        .formStyle(.grouped)
    }
}

#Preview {
    SettingsView()
        // Sets the window's width and height
        .frame(width: 350, height: 115)
}
