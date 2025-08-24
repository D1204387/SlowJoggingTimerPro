//
//  SoundscapeKind.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/24.
//

import Foundation

    /// 新版「音場」定義（不影響現有 MusicType）
    /// - 未改 TimerManager 前，城市/專注先 fallback 到 .lightMusic，自然音到 .nature
enum SoundscapeKind: String, CaseIterable, Identifiable {
    case light      = "輕音樂｜舒緩旋律"
    case nature     = "自然音｜森林/海浪"
    case city       = "城市清晨｜Lo-fi 低節奏"
    case focus      = "專注氛圍｜環境脈衝"
    
    var id: String { rawValue }
    
    var emoji: String {
        switch self {
        case .light:  return "🎵"
        case .nature: return "🌿"
        case .city:   return "🌆"
        case .focus:  return "🫧"
        }
    }
    
    var title: String {
        rawValue.split(separator: "｜").first.map(String.init) ?? rawValue
    }
    
    var subtitle: String {
        rawValue.split(separator: "｜").dropFirst().first.map(String.init) ?? ""
    }
    
        /// 預計對應到的音檔（之後你可在 TimerManager 用它來挑不同檔案）
    var assetName: String {
        switch self {
        case .light:  return "light_music"
        case .nature: return "nature_ambient"
        case .city:   return "city_lofi"        // 之後可新增檔案
        case .focus:  return "ambient_pulse"    // 之後可新增檔案
        }
    }
    
        /// 與現有 MusicType 的暫時對應（不改 TimerManager 也能先用）
    var fallbackMusicType: MusicType {
        switch self {
        case .nature: return .nature
        default:      return .lightMusic
        }
    }
}
