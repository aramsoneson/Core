//
//  CoreApp.swift
//  Core
//
//  Created by Aram Soneson on 2/17/25.
//

import SwiftUI

@main
struct CoreApp: App {
    // Makes sure cpuMonitor persists for the lifetime of the app
    @StateObject private var cpuMonitor = CPUMonitor()
    // Defines the variable to open windows
    @Environment(\.openWindow) private var openWindow
    // Defines the variable for the menu bar item's icon
    @AppStorage("menuBarIcon") private var menuBarIcon: String = "cpu"
    // Defines the variable for whether the Welcome window opens
    @AppStorage("shouldWelcome") var shouldWelcome: Bool = true
            
    var body: some Scene {
        // Defines the menu bar item
        MenuBarExtra {
            // Defines the button that links to the About window
            Button("About") {
                openWindow(id: "about")
            }
            
            // Defines the button that links to the Settings window
            SettingsLink {
                Label("Settings", systemImage: "gearshape")
            }
            // Adds the keyboard shortcut tooltip
            .keyboardShortcut(",", modifiers: .command)
            
            Divider()
            
            // Defines the button that quits the app
            Button("Quit") {
                NSApp.terminate(nil)
            }
            // Adds the keyboard shortcut tooltip
            .keyboardShortcut("Q", modifiers: .command)
        }
        // Defines the menu bar item's content that is displayed in the menu bar itself
        label: {
            HStack {
                Image(systemName: menuBarIcon)
                Text(cpuMonitor.cpuUsage)
            }
        }
        
        // Defines the About window
        Window("About", id: "about") {
            AboutView()
                // Removes the window toolbar's title text and background
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
                
                // Disables the window controls to minimize and maximize the window (yellow and green traffic lights)
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
                .windowResizeBehavior(.disabled)
                
                // Sets the window's width and height
                .frame(maxWidth: 250, maxHeight: 300)
        }
        // Sets the window to sit on top of all other windows
        .windowLevel(.floating)
        // Sets the window to resize around the content
        .windowResizability(.contentSize)
        
        // Defines the Welcome window
        Window("Welcome", id: "welcome") {
            WelcomeView()
                // Removes the window toolbar's title text and background
                .toolbar(removing: .title)
                .toolbarBackground(.hidden, for: .windowToolbar)
            
                // Disables the window controls to close, minimize, and maximize the window (traffic lights)
                .windowDismissBehavior(.disabled)
                .windowMinimizeBehavior(.disabled)
                .windowFullScreenBehavior(.disabled)
                .windowResizeBehavior(.disabled)
            
                // Sets the window's width and height
                .frame(maxWidth: 420, maxHeight: 480)
        }
        // Sets the window to sit on top of all other windows
        .windowLevel(.floating)
        //Sets the window to open on launch if shouldLaunchWelcome = true
        .defaultLaunchBehavior(shouldWelcome ? .presented : .automatic)
        // Sets the window to resize around the content
        .windowResizability(.contentSize)
        
        // Defines the Settings window
        Settings {
            SettingsView()
                // Removes the window toolbar's background
                .toolbarBackground(.hidden, for: .windowToolbar)
            
                // Sets the window's width and height
                .frame(maxWidth: 350, maxHeight: 115)
        }
        // Sets the window to sit on top of all other windows
        .windowLevel(.floating)
    }
}

// Defines the class that monitors CPU usage and allows views to react to changes
class CPUMonitor: ObservableObject {
    // Defines the variable for the number of decimal places the percentage goes out to
    @AppStorage("decimalPlaces") private var decimalPlaces: Int = 1

    // Defines the default value of cpuUsage that will change when updated
    @Published var cpuUsage: String = "Calculating..."
    // Stores the previous CPU information to calculate the difference over time
    private var previousCPULoadInfo = host_cpu_load_info()
    // Defines the timer that will update the CPU usage at an interval and ensures that it will continue running
    private var timer: Timer?
    
    // Starts the monitoring process
    init() {
        // Sets the initial CPU usage data
        updatePreviousCPULoadInfo()
        // Starts the actual monitoring process
        startCPUMonitoring()
    }
    
    // Fetches and stores the current CPU usage data to be used later
    private func updatePreviousCPULoadInfo() {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        let result = withUnsafeMutablePointer(to: &previousCPULoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        // Defines what to do in case of an error
        if result != KERN_SUCCESS {
            print("Error retrieving CPU load: \(result)")
        }
    }
    
    // Starts the timer
    func startCPUMonitoring() {
        // Ensures that the following actions will be repeated twice a second
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if let usage = self.calculateCPUUsage() {
                // Output the cpuUsage variably with two decimal places
                DispatchQueue.main.async {
                    self.cpuUsage = String(format: "%.\(self.decimalPlaces)f%%", usage)
                }
            }
        }
    }
    
    // Computes the current CPU usage percentage
    func calculateCPUUsage() -> Double? {
        var size = mach_msg_type_number_t(MemoryLayout<host_cpu_load_info_data_t>.size / MemoryLayout<integer_t>.size)
        var currentCPULoadInfo = host_cpu_load_info()
        let result = withUnsafeMutablePointer(to: &currentCPULoadInfo) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(size)) {
                host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, $0, &size)
            }
        }
        
        // Defines what to do in case of an error
        guard result == KERN_SUCCESS else {
            print("Error retrieving CPU load: \(result)")
            return nil
        }
        
        // Defines the variable that represents the difference in CPU usage by user processes
        let userDiff = Double(currentCPULoadInfo.cpu_ticks.0 - previousCPULoadInfo.cpu_ticks.0)
        // Defines the variable that represents the difference in CPU usage by system processes
        let systemDiff = Double(currentCPULoadInfo.cpu_ticks.1 - previousCPULoadInfo.cpu_ticks.1)
        // Defines the variable that represents the difference in CPU non-usage
        let idle = Double(currentCPULoadInfo.cpu_ticks.2 - previousCPULoadInfo.cpu_ticks.2)
        // Defines the variable that represents the difference in CPU usage by low-priority user processes
        let nice = Double(currentCPULoadInfo.cpu_ticks.3 - previousCPULoadInfo.cpu_ticks.3)
        // "Nice" channel is grouped into "idle" to match Activity Monitor's method
        let idleDiff = idle + nice
        
        // Defines the total CPU usage, including CPU non-usage
        let totalTicks = userDiff + systemDiff + idleDiff
        // Outputs the percentage of CPU usage by dividing the user and system processes by the total
        let cpuUsage = (userDiff + systemDiff) / totalTicks * 100.0
        
        if cpuUsage.isNaN {
            return nil
        }
        
        // Updates previousCPULoadInfo to ready it for the next calculation
        previousCPULoadInfo = currentCPULoadInfo
        
        // Outputs the percentage value
        return cpuUsage
    }
    
    // Removes the timer when the instance is deallocated
    deinit {
        timer?.invalidate()
    }
}
