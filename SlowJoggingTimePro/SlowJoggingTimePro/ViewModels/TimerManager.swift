//
//  TimerManager.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import Foundation
import AVFoundation

@Observable
@MainActor
class TimerManager {
    var currentTime: TimeInterval = 0
    var targetDuration: TimeInterval = 1800 // 30分鐘預設
    var selectedMusic: MusicType = .lightMusic
    var isRunning = false
    var isPaused = false
    var steps = 0
    var records: [JoggingRecord] = []
    
    private var timer: Timer?
    
    init() {
        print("✅ TimerManager 初始化成功")
    }
    
    var progress: Double {
        guard targetDuration > 0 else { return 0 }
        return min(currentTime / targetDuration, 1.0)
    }
    
    var formattedTime: String {
        let hours = Int(currentTime) / 3600
        let minutes = Int(currentTime) % 3600 / 60
        let seconds = Int(currentTime) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var remainingTime: String {
        let remaining = max(0, targetDuration - currentTime)
        let minutes = Int(remaining) / 60
        let seconds = Int(remaining) % 60
        return String(format: "剩餘 %d:%02d", minutes, seconds)
    }
    
        // 簡化版的計時器功能（第一步測試用）
    func startTimer() {
        isRunning = true
        isPaused = false
        print("✅ 計時器啟動 - 目標時間: \(Int(targetDuration/60))分鐘")
    }
    
    func pauseTimer() {
        isRunning = false
        isPaused = true
        print("⏸️ 計時器暫停")
    }
    
    func stopTimer() {
        isRunning = false
        isPaused = false
        currentTime = 0
        steps = 0
        print("⏹️ 計時器停止")
    }
    
        // 測試用：更新目標時間
    func updateTargetDuration(_ minutes: Double) {
        targetDuration = minutes * 60
        print("🎯 目標時間更新為: \(Int(minutes))分鐘")
    }
    
        // 測試用：切換音樂
    func updateMusic(_ music: MusicType) {
        selectedMusic = music
        print("🎵 音樂切換為: \(music.rawValue)")
    }
}
