//
//  BeautifulBackground.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct BeautifulBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.97, green: 0.98, blue: 1.0),
                Color(red: 0.94, green: 0.96, blue: 1.0)
//                .blue.opacity(0.3),     // 明顯的藍色
//                .purple.opacity(0.3)    // 明顯的紫色
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

#Preview("漸層背景") {
    BeautifulBackground()
}
