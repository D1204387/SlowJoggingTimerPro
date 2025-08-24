//
//  MusicType.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import Foundation

enum MusicType: String, CaseIterable, Codable {
    case lightMusic = "輕音樂"
    case nature     = "自然音"
}

extension MusicType {
    var emoji: String {
        switch self {
        case .lightMusic: return "🎵"
        case .nature:     return "🌿"
        }
    }
        /// 更像音場的副標
    var description: String {
        switch self {
        case .lightMusic: return "舒緩旋律"
        case .nature:     return "森林／海浪"
        }
    }
}
