//
//  ContentView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct ContentView: View {
    @State private var timerManager = TimerManager()
    
        // 定義顏色
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    private let lightBlue = Color(red: 0.85, green: 0.93, blue: 1.0)
    
    var body: some View {
        ZStack {
            BeautifulBackground()
            
            VStack(spacing: 30) {
                    // 標題
                VStack(spacing: 12) {
                    Text("🏃‍♂️ 超慢跑計時器 Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(primaryBlue)
                    
                    Text("進階版本 - 第一步測試")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                    // 狀態卡片
                VStack(spacing: 16) {
                    statusCard
                    testControls
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .padding(.top, 40)
        }
    }
    
    private var statusCard: some View {
        VStack(spacing: 12) {
            Text("📊 當前狀態")
                .font(.headline)
                .foregroundColor(primaryBlue)
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("🎯 目標時間:")
                    Spacer()
                    Text("\(Int(timerManager.targetDuration / 60)) 分鐘")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("🎵 背景音樂:")
                    Spacer()
                    Text(timerManager.selectedMusic.rawValue)
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("⏱️ 計時狀態:")
                    Spacer()
                    Text(timerManager.isRunning ? "運行中" : (timerManager.isPaused ? "已暫停" : "停止"))
                        .fontWeight(.semibold)
                        .foregroundColor(timerManager.isRunning ? .green : (timerManager.isPaused ? .orange : .red))
                }
                
                HStack {
                    Text("⏰ 當前時間:")
                    Spacer()
                    Text(timerManager.formattedTime)
                        .fontWeight(.semibold)
                        .foregroundColor(primaryBlue)
                }
            }
            .font(.subheadline)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.9))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var testControls: some View {
        VStack(spacing: 16) {
            Text("🧪 測試控制")
                .font(.headline)
                .foregroundColor(primaryBlue)
            
                // 時間測試
            HStack(spacing: 12) {
                Button("15分") { timerManager.updateTargetDuration(15) }
                Button("30分") { timerManager.updateTargetDuration(30) }
                Button("45分") { timerManager.updateTargetDuration(45) }
                Button("60分") { timerManager.updateTargetDuration(60) }
            }
            .buttonStyle(.bordered)
            
                // 音樂測試
            HStack(spacing: 8) {
                ForEach(MusicType.allCases, id: \.self) { music in
                    Button(music.emoji) {
                        timerManager.updateMusic(music)
                    }
                    .buttonStyle(.bordered)
                }
            }
            
                // 計時器測試
            HStack(spacing: 12) {
                Button("開始") {
                    timerManager.startTimer()
                }
                .buttonStyle(.borderedProminent)
                
                Button("暫停") {
                    timerManager.pauseTimer()
                }
                .buttonStyle(.bordered)
                
                Button("停止") {
                    timerManager.stopTimer()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(lightBlue.opacity(0.3))
        )
    }
}

#Preview("第一步測試") {
    ContentView()
}
