//
//  SlowJoggingTimeProApp.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

@main
struct SlowJoggingTimeProApp: App {
    @State private var timer = TimerManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timer)
        }
    }
}
