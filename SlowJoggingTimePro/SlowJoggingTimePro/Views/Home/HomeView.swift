    //
    //  HomeView.swift
    //  SlowJoggingTimePro
    //
    //  Created by YiJou  on 2025/8/23.
    //
    //

import SwiftUI

struct HomeView: View {
    @Environment(TimerManager.self) private var timerManager
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    private let cardBG      = Color.white.opacity(0.92)
    private let tipText     = RunTips.tipOfThisLaunch
    
    var body: some View {
        NavigationStack {
            ZStack {
                BeautifulBackground().ignoresSafeArea()
                
                VStack(spacing: 10) {
                    headerSection
                    tipCard
                    
                    sectionHeader(title: "運動時間", emoji: "⏱️")
                    GlassCard { TimeSliderView(compact: true) }
                    
                    sectionHeader(title: "背景音樂", emoji: "🎵")
//                    GlassCard { MusicSelectionView() }
                    GlassCard { SoundscapePickerView() }
                    
                    Spacer(minLength: 0) // 內容自然結束；底部 CTA 交給 toolbar
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .toolbar(.hidden, for: .navigationBar)
                // ✅ 把 CTA 放在底部工具列，永遠在 Tab bar 之上，不重疊
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    bottomCTA
                }
            }
            .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
            .toolbarBackground(.visible, for: .bottomBar)
        }
    }
    
        // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 4) {
            HStack(spacing: 10) {
                Text("🏃‍♂️").font(.system(size: 26))
                Text("超慢跑")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
            }
            .foregroundColor(primaryBlue)
            
            Text("輕鬆開始每一天")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var tipCard: some View {
        HStack(spacing: 12) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(.yellow)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("今日小提示")
                    .font(.headline)
                    .foregroundColor(primaryBlue)
                
                Text(tipText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(cardBG)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }
    
    private func sectionHeader(title: String, emoji: String) -> some View {
        HStack(spacing: 8) {
            Text(emoji).font(.title3)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            Spacer(minLength: 0)
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 4)
        .padding(.top, 2)
    }
    
        // MARK: - Bottom CTA（出現在 Tab bar 之上）
    private var bottomCTA: some View {
        Button {
            timerManager.startTimer()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "play.fill").font(.headline)
                Text("開始超慢跑")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .frame(width: 150)
            .frame(height: 56)
            .background(
                LinearGradient(colors: [primaryBlue, primaryBlue.opacity(0.85)],
                               startPoint: .leading, endPoint: .trailing)
            )
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: primaryBlue.opacity(0.28), radius: 12, x: 0, y: 6)
            .scaleEffect(timerManager.isRunning ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: timerManager.isRunning)
        }
        .disabled(timerManager.isRunning)
        .opacity(timerManager.isRunning ? 0.6 : 1)
        .padding(.horizontal, 20)   // ← 與左右邊緣拉開
    }
}

    // MARK: - Reusable Glass Card
private struct GlassCard<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(Color.white.opacity(0.65), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 6)
            
            content
                .padding(12)
        }
    }
}

#Preview("主頁面") {
    HomeView()
        .environment(TimerManager())
}
