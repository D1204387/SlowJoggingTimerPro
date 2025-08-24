//
//  RunTips.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/24.
//

import Foundation

/// 超慢跑一行小提示提供者
enum RunTips {
    /// 7 條一行提示（與超慢跑相關）
    static let all: [String] = [
        "邊跑能說話的節奏，呼吸不憋氣",
        "步幅小步頻穩，腳掌輕點地",
        "身體微前傾，放鬆肩頸與雙手",
        "先走 3 分鐘熱身再開始慢跑",
        "每 10 分鐘掃描身體，放鬆臉與下巴",
        "口渴前小口補水，不要一次灌太多",
        "結束後走 5 分鐘放鬆並做伸展"
    ]
    
    /// 本次啟動固定的一句（App 重啟才會更換）
    static let tipOfThisLaunch: String = {
        all.randomElement() ?? all.first!
    }()
    
    /// （可選）每天固定一句：同一天回傳同一句，跨天才換
    static func tipForToday() -> String {
        let defaults = UserDefaults.standard
        let dateKey  = "RunTips.lastDate"
        let tipKey   = "RunTips.lastTip"
        
            // 取「今天」的起始時間字串做為 key（避免跨時區混亂）
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let todayKey = ISO8601DateFormatter().string(from: startOfDay)
        
        if defaults.string(forKey: dateKey) == todayKey,
           let saved = defaults.string(forKey: tipKey) {
            return saved
        } else {
            let new = all.randomElement() ?? all.first!
            defaults.set(todayKey, forKey: dateKey)
            defaults.set(new, forKey: tipKey)
            return new
        }
    }
}

