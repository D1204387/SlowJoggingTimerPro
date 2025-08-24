//
//  ContentView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct ContentView: View {
    @State private var timerManager = TimerManager()
    @State private var selectedTab = 0
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
    var body: some View {
        TabView(selection: $selectedTab) {
                // 分頁 1：跑步（包裝：內部切換 Home / Running）
            RunRootView()
                .tabItem { Label("跑步", systemImage: "timer") }
                .tag(0)
            
                // 分頁 2：記錄
            RecordsView()
                .tabItem { Label("記錄", systemImage: "chart.bar.fill") }
                .tag(1)
        }
        .tint(primaryBlue)
            // ✅ 只在最外層注入一次
        .environment(timerManager)
        .onChange(of: timerManager.isRunning) { _, newValue in
            if newValue { selectedTab = 0 }
        }
        .onChange(of: timerManager.isPaused) { _, newValue in
            if newValue { selectedTab = 0 }
        }
    }
}

    /// 專門決定顯示 Home 還是 Running 的容器（保持 Tab 結構穩定）
private struct RunRootView: View {
    @Environment(TimerManager.self) private var timerManager
    
    var body: some View {
        Group {
            if timerManager.isRunning || timerManager.isPaused {
                RunningTimerView()
            } else {
                HomeView()
            }
        }
            // ✅ 把完成動畫的 cover 綁在這層（這層不會被移除）
        .fullScreenCover(
            isPresented: .init(
                get: { timerManager.showCompletionAnimation },
                set: { newValue in
                    if !newValue {
                            // 關閉動畫時才重置，避免數字一閃就歸零
                        timerManager.resetAfterCompletion()
                    }
                    timerManager.showCompletionAnimation = newValue
                }
            )
        ) {
            CompletionAnimationView(
                onDismiss: {
                        // 使用者點「完成」
                    timerManager.dismissCompletionAnimationAndReset()
                }
            )
        }
    }
}

#Preview {
    ContentView()
}

