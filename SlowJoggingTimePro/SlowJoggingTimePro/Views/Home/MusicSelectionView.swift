//
//  MusicSelectionView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct MusicSelectionView: View {
    @Environment(TimerManager.self) private var timer
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
    var body: some View {
        VStack(spacing: 12) {
                // 兩格音場卡
            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)],
                      spacing: 12) {
                ForEach(MusicType.allCases, id: \.self) { music in
                    musicCard(music)
                }
            }
            
                // 永遠顯示：節拍器 BPM（無開關）
            HStack(spacing: 10) {
                Label("配速節拍器", systemImage: "metronome.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Picker("", selection: Binding(
                    get: { timer.metronomeBPM },
                    set: { timer.setMetronomePreset($0) }
                )) {
                    Text("90 BPM").tag(90)
                    Text("180 BPM").tag(180)
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 220)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.92))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.65), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
    
        // MARK: - 音場卡
    private func musicCard(_ music: MusicType) -> some View {
        let isSelected = timer.selectedMusic == music
        
        return Button {
            timer.selectedMusic = music
        } label: {
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(music.emoji).font(.subheadline)
                        Text(music.rawValue)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    Text(music.description)
                        .font(.caption2)
                        .opacity(0.75)
                }
                Spacer()
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isSelected ? primaryBlue : .gray.opacity(0.4))
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .frame(height: 86)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryBlue.opacity(0.1) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? primaryBlue : Color.gray.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1)
                    )
            )
            .foregroundColor(isSelected ? primaryBlue : .primary)
            .shadow(color: isSelected ? primaryBlue.opacity(0.16) : Color.black.opacity(0.06),
                    radius: isSelected ? 8 : 3, x: 0, y: 3)
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

#Preview("音樂 + 永遠節拍器") {
    MusicSelectionView()
        .environment(TimerManager())
        .padding()
}
