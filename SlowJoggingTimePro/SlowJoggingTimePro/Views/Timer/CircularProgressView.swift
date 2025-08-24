//
//  CircularProgressView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct CircularProgressView: View {
    @Environment(TimerManager.self) private var timerManager
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
    var body: some View {
        ZStack {
                // 背景圓圈
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 12)
                .frame(width: 280, height: 280)
            
                // 進度圓圈
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(
                    LinearGradient(
                        colors: [primaryBlue, primaryBlue.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                )
                .frame(width: 280, height: 280)
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1.0), value: timerManager.progress)
            
                // 中央內容
            VStack(spacing: 12) {
                Text(timerManager.formattedTime)
                    .font(.system(size: 36, weight: .bold, design: .monospaced))
                    .foregroundColor(primaryBlue)
                
                Text(timerManager.remainingTime)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                    // 運動狀態指示器
                HStack(spacing: 8) {
                    Circle()
                        .fill(timerManager.isRunning ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                        .scaleEffect(timerManager.isRunning ? 1.2 : 1.0)
                        .animation(
                            timerManager.isRunning ?
                                .easeInOut(duration: 0.6).repeatForever(autoreverses: true) :
                                    .default,
                            value: timerManager.isRunning
                        )
                    
                    Text(timerManager.isRunning ? "運動中" : (timerManager.isPaused ? "已暫停" : "已停止"))
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(timerManager.isRunning ? .green : .orange)
                }
            }
        }
    }
}

#Preview("圓形進度條") {
    let timerManager = TimerManager()
    timerManager.currentTime = 600 // 10分鐘
    timerManager.targetDuration = 1800 // 30分鐘
    timerManager.isRunning = true
    
    return CircularProgressView()
        .environment(timerManager)
        .padding()
}
