//
//  MusicType.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import Foundation

enum MusicType: String, CaseIterable {
    case lightMusic = "輕音樂"
    case metronome = "節拍器"
    case nature = "自然音"
    case silent = "靜音"
    
    var emoji: String {
        switch self {
        case .lightMusic: return "🎵"
        case .metronome: return "🥁"
        case .nature: return "🌿"
        case .silent: return "🔇"
        }
    }
    
    var description: String {
        switch self {
        case .lightMusic: return "舒緩音樂"
        case .metronome: return "180 BPM"
        case .nature: return "鳥鳴流水"
        case .silent: return "無聲音"
        }
    }
}
