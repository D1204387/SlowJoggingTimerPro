//
//  CompletionAnimationView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI

struct CompletionAnimationView: View {
    @Environment(TimerManager.self) private var timerManager
    @Environment(\.dismiss) private var dismiss
    
    let onDismiss: (() -> Void)?
    
    @State private var showAnimation = false
    @State private var showContent = false
    @State private var confettiAnimation = false
    @State private var starScale: [CGFloat] = Array(repeating: 0, count: 5)
    @State private var motivationalText = ""
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    private let motivationalTexts = [
        "太棒了！堅持就是勝利！",
        "優秀！今天的你戰勝了昨天的自己！",
        "完美！每一步都是進步！",
        "了不起！你做到了！",
        "精彩！繼續保持這份熱情！"
    ]
    
    init(onDismiss: (() -> Void)? = nil) {
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color(red: 0.95, green: 0.98, blue: 1.0),
                                            primaryBlue.opacity(0.1)]),
                startPoint: .top, endPoint: .bottom
            )
            .ignoresSafeArea()
            
            if confettiAnimation { ConfettiView() }
            
            VStack(spacing: 28) {
                Spacer()
                
                completionIcon
                
                if showContent {
                    Text(motivationalText)
                        .font(.title3.weight(.bold))
                        .foregroundColor(primaryBlue)
                        .multilineTextAlignment(.center)
                        .transition(.scale.combined(with: .opacity))
                }
                
                if showContent {
                    summaryCard
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                if showContent {
                    starRating
                        .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                if showContent {
                    actionButtons
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding()
        }
        .onAppear {
            startAnimations()
            selectRandomMotivationalText()
        }
    }
    
        // MARK: - Icon
    private var completionIcon: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryBlue.opacity(0.3), primaryBlue.opacity(0.1)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 3
                )
                .frame(width: 150, height: 150)
                .scaleEffect(showAnimation ? 1.5 : 0)
                .opacity(showAnimation ? 0 : 1)
                .animation(.easeOut(duration: 1.5), value: showAnimation)
            
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color.green.opacity(0.3),
                                                                 Color.green.opacity(0.1)]),
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 120, height: 120)
                .scaleEffect(showAnimation ? 1.2 : 0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1),
                           value: showAnimation)
            
            Circle()
                .fill(Color.green)
                .frame(width: 100, height: 100)
                .scaleEffect(showAnimation ? 1 : 0)
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.2),
                           value: showAnimation)
            
            Image(systemName: "checkmark")
                .font(.system(size: 50, weight: .bold))
                .foregroundColor(.white)
                .scaleEffect(showAnimation ? 1 : 0)
                .rotationEffect(.degrees(showAnimation ? 0 : -180))
                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.3),
                           value: showAnimation)
        }
    }
    
        // MARK: - Summary
    private var summaryCard: some View {
        VStack(spacing: 18) {
            Text("運動總結")
                .font(.headline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                SummaryItem(icon: "timer",
                            value: timerManager.formattedTime,
                            label: "運動時間",
                            color: primaryBlue)
                
                SummaryItem(icon: "target",
                            value: "\(Int(timerManager.targetDuration / 60))分",
                            label: "目標時間",
                            color: .orange)
            }
            
                // 完成度
            HStack(spacing: 10) {
                Image(systemName: "chart.pie.fill")
                    .foregroundColor(getCompletionColor())
                Text("完成度 \(Int(timerManager.progress * 100))%")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(getCompletionColor())
            }
            .padding(.top, 6)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: primaryBlue.opacity(0.1), radius: 10, x: 0, y: 5)
        )
    }
    
        // MARK: - Stars
    private var starRating: some View {
        VStack(spacing: 10) {
            Text("今天的表現")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                ForEach(0..<5) { i in
                    Image(systemName: getStarImage(for: i))
                        .font(.title2)
                        .foregroundColor(.yellow)
                        .scaleEffect(starScale[i])
                        .animation(.spring(response: 0.3, dampingFraction: 0.6).delay(Double(i) * 0.1),
                                   value: starScale[i])
                }
            }
        }
    }
    
        // MARK: - Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: shareResult) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("分享成果")
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(
                    LinearGradient(colors: [primaryBlue, primaryBlue.opacity(0.85)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            
            Button {
                onDismiss?()
                dismiss()
            } label: {
                Text("完成")
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.gray.opacity(0.1))
                    .foregroundColor(.primary)
                    .cornerRadius(15)
            }
        }
        .padding(.horizontal)
    }
    
        // MARK: - Helpers
    private func startAnimations() {
        withAnimation { showAnimation = true; confettiAnimation = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.spring()) { showContent = true }
        }
        for i in 0..<5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0 + Double(i) * 0.1) {
                starScale[i] = 1.0
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { confettiAnimation = false }
    }
    
    private func selectRandomMotivationalText() {
        motivationalText = motivationalTexts.randomElement() ?? "太棒了！"
    }
    
    private func getCompletionColor() -> Color {
        let p = timerManager.progress
        if p >= 1.0 { return .green }
        else if p >= 0.8 { return .orange }
        else { return .red }
    }
    
    private func getStarImage(for index: Int) -> String {
        let p = timerManager.progress
        let filled = Int(p * 5)
        if index < filled { return "star.fill" }
        else if index == filled && (p * 5).truncatingRemainder(dividingBy: 1) >= 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    private func shareResult() {
        let text = """
        我剛完成了 \(timerManager.formattedTime) 的超慢跑！
        完成度：\(Int(timerManager.progress * 100))%
        音場：\(timerManager.selectedMusic.rawValue)｜節拍 \(timerManager.metronomeBPM) BPM
        #超慢跑 #健康生活
        """
        print(text)
    }
}

    // MARK: - Reusable Summary Item
struct SummaryItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

    // MARK: - Confetti（維持原實作）
struct ConfettiView: View {
    @State private var animate = false
    var body: some View {
        ZStack {
            ForEach(0..<50) { index in
                ConfettiPiece(animate: $animate, index: index)
            }
        }
        .onAppear { animate = true }
    }
}

struct ConfettiPiece: View {
    @Binding var animate: Bool
    let index: Int
    private let colors: [Color] = [.red, .green, .blue, .yellow, .orange, .purple, .pink]
    
    var body: some View {
        let randomX = CGFloat.random(in: -200...200)
        let randomY = CGFloat.random(in: -500...(-100))
        Rectangle()
            .fill(colors.randomElement() ?? .blue)
            .frame(width: 10, height: 10)
            .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
            .offset(x: animate ? randomX : 0, y: animate ? 600 : randomY)
            .opacity(animate ? 0 : 1)
            .animation(.easeOut(duration: 3).delay(Double(index) * 0.02),
                       value: animate)
    }
}

#Preview("完成動畫（精簡版）") {
    CompletionAnimationView()
        .environment(TimerManager())
}
