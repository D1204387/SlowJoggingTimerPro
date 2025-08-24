//
//  SoundscapePickerView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/24.
//

import SwiftUI

    /// 新版音場選擇 UI（不影響舊版 MusicSelectionView）
struct SoundscapePickerView: View {
    @Environment(TimerManager.self) private var timerManager
    
        // 直接存字串；用只讀的 computed 把它轉回 enum
    @AppStorage("SelectedSoundscapeKind")
    private var selectedRaw: String = SoundscapeKind.light.rawValue
    
    private var selectedKind: SoundscapeKind {
        SoundscapeKind(rawValue: selectedRaw) ?? .light
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(SoundscapeKind.allCases) { kind in
                card(for: kind)
            }
        }
        .onAppear {
                // 與 TimerManager 的舊欄位 selectedMusic 做一次同步
            timerManager.updateSoundscape(selectedKind)
        }
    }
    
    @ViewBuilder
    private func card(for kind: SoundscapeKind) -> some View {
        let isSelected = (kind == selectedKind)
        
        Button {
                // ✅ 改「底層儲存」而不是改計算屬性，避免 'self is immutable'
            selectedRaw = kind.rawValue
            timerManager.updateSoundscape(kind)
        } label: {
            VStack(spacing: 6) {
                HStack(spacing: 6) {
                    Text(kind.emoji).font(.title3)
                    Text(kind.title)
                        .font(.subheadline).fontWeight(.medium)
                        .lineLimit(1)
                }
                Text(kind.subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected ? primaryBlue.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? primaryBlue : Color.gray.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1)
                    )
            )
            .foregroundColor(isSelected ? primaryBlue : .primary)
            .shadow(color: isSelected ? primaryBlue.opacity(0.18) : Color.black.opacity(0.05),
                    radius: isSelected ? 8 : 3, x: 0, y: 3)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

#Preview("音場選擇（新版）") {
    SoundscapePickerView()
        .environment(TimerManager())
        .padding()
}
