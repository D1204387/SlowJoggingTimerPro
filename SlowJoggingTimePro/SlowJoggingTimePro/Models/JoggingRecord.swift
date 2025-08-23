//
//  JoggingRecord.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import Foundation

struct JoggingRecord: Identifiable, Codable {
    var id = UUID()
    let duration: TimeInterval
    let targetDuration: TimeInterval
    let date: Date
    let musicType: String
    let steps: Int
    let calories: Int
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    var completionPercentage: Double {
        guard targetDuration > 0 else { return 0 }
        return min(duration / targetDuration, 1.0) * 100
    }
}
