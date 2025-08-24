    //
    //  RunningTimerView.swift
    //  SlowJoggingTimePro
    //

    //
    //  RunningTimerView.swift
    //  SlowJoggingTimePro
    //

import SwiftUI

struct RunningTimerView: View {
    @Environment(TimerManager.self) private var timer
    @State private var showStopAlert = false
    @State private var showCompletionView = false
    @State private var animationAmount: CGFloat = 1
    @State private var pulseAnimation = false
    
        // for animatedBackground：一次產生的隨機位移，避免每次重繪跳動
    @State private var bubbleOffsets: [CGSize] = []
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    private let lightBlue = Color(red: 0.85, green: 0.93, blue: 1.0)
    
    var body: some View {
        ZStack {
            animatedBackground
            
            VStack(spacing: 30) {
                headerView
                
                Spacer()
                
                circularProgressView
                
                    // 簡潔即時資訊（移除步數/卡路里）
                liveInfoRow
                
                Spacer()
                
                controlButtons
                
                Spacer().frame(height: 40)
            }
            .padding(.horizontal)
        }
        .onAppear {
            startAnimations()
            if bubbleOffsets.isEmpty {
                    // 只算一次，避免每次 render 都跳
                bubbleOffsets = [
                    CGSize(width: -80, height: 40),
                    CGSize(width: 60, height: 240),
                    CGSize(width: -20, height: 440)
                ]
            }
        }
        .onChange(of: timer.showCompletionAnimation) { _, newValue in
            if newValue {
                showCompletionView = true
                timer.showCompletionAnimation = false
            }
        }
        .alert("結束運動", isPresented: $showStopAlert) {
            Button("取消", role: .cancel) { }
            Button("結束", role: .destructive) {
                showCompletionView = true
                timer.stopTimer()
            }
        } message: {
            Text("確定要結束這次運動嗎？")
        }
        .fullScreenCover(isPresented: $showCompletionView) {
            CompletionAnimationView(onDismiss: {
                timer.resetAfterCompletion()
            })
        }
    }
    
        // MARK: - 動態背景（使用固定 offsets，避免隨機跳動）
    private var animatedBackground: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [lightBlue, Color.white, lightBlue.opacity(0.5)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            GeometryReader { geo in
                ForEach(0..<3, id: \.self) { index in
                    let offset = bubbleOffsets.indices.contains(index) ? bubbleOffsets[index] : .zero
                    Circle()
                        .fill(primaryBlue.opacity(0.05))
                        .frame(width: 200, height: 200)
                        .scaleEffect(pulseAnimation ? 1.2 : 1.0)
                        .offset(x: offset.width, y: offset.height)
                        .animation(
                            Animation.easeInOut(duration: 4)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.5),
                            value: pulseAnimation
                        )
                }
            }
        }
    }
    
        // MARK: - 頂部標題（顯示音場）
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("超慢跑進行中")
                .font(.title2).fontWeight(.bold)
                .foregroundColor(primaryBlue)
            
                // ✅ 顯示 SoundscapeKind（emoji + 標題｜副標）
            HStack(spacing: 8) {
                Text(timer.selectedSoundscape.emoji).font(.caption)
                Text(timer.selectedSoundscape.rawValue)
                    .font(.subheadline)
                    .lineLimit(1)
            }
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(Color.white.opacity(0.85))
            )
            
#if DEBUG
//            Button("測試完成動畫") {
//                showCompletionView = true
//            }
//            .font(.caption)
//            .padding(.horizontal, 10)
//            .padding(.vertical, 5)
//            .background(Color.purple.opacity(0.2))
//            .cornerRadius(8)
#endif
        }
        .padding(.top, 20)
    }
    
        // MARK: - 圓形進度環
    private var circularProgressView: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryBlue.opacity(0.3), primaryBlue.opacity(0.1)]),
                        startPoint: .topLeading, endPoint: .bottomTrailing
                    ),
                    lineWidth: 20
                )
                .frame(width: 280, height: 280)
                .scaleEffect(animationAmount)
                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true),
                           value: animationAmount)
            
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 24)
                .frame(width: 250, height: 250)
            
            Circle()
                .trim(from: 0, to: timer.progress)
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [primaryBlue, primaryBlue.opacity(0.7)]),
                        startPoint: .leading, endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 24, lineCap: .round)
                )
                .frame(width: 250, height: 250)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear(duration: 1), value: timer.progress)
            
            VStack(spacing: 16) {
                Text(timer.formattedTime)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(primaryBlue)
                
                Text(timer.remainingTime)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 4) {
                    Image(systemName: "chart.pie.fill").font(.caption)
                    Text("\(Int(timer.progress * 100))%")
                        .font(.subheadline).fontWeight(.medium)
                }
                .foregroundColor(getProgressColor())
            }
        }
    }
    
        // MARK: - 即時資訊（不顯示步數/卡路里）
    private var liveInfoRow: some View {
        HStack(spacing: 20) {
            SimpleStat(icon: "timer", title: "已用", value: timer.formattedTime, color: .blue)
            SimpleStat(icon: "hourglass", title: "剩餘", value: remainingCompact(), color: .orange)
            SimpleStat(icon: "gauge", title: "完成", value: "\(Int(timer.progress * 100))%", color: .green)
        }
        .padding(.horizontal)
    }
    
        // MARK: - 控制按鈕
    private var controlButtons: some View {
        HStack(spacing: 20) {
            Button(action: {
                if timer.isPaused { timer.resumeTimer() } else { timer.pauseTimer() }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: timer.isPaused ? "play.fill" : "pause.fill").font(.title2)
                    Text(timer.isPaused ? "繼續" : "暫停")
                        .font(.headline).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            timer.isPaused ? Color.green : Color.orange,
                            timer.isPaused ? Color.green.opacity(0.8) : Color.orange.opacity(0.8)
                        ]),
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: (timer.isPaused ? Color.green : Color.orange).opacity(0.3),
                        radius: 8, x: 0, y: 4)
            }
            
            Button(action: { showStopAlert = true }) {
                HStack(spacing: 8) {
                    Image(systemName: "stop.fill").font(.title2)
                    Text("結束").font(.headline).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity).frame(height: 56)
                .background(
                    LinearGradient(colors: [Color.red, Color.red.opacity(0.8)],
                                   startPoint: .leading, endPoint: .trailing)
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color.red.opacity(0.3), radius: 8, x: 0, y: 4)
            }
        }
        .padding(.horizontal)
    }
    
        // MARK: - Helpers
    private func startAnimations() {
        animationAmount = 1.1
        pulseAnimation = true
    }
    
    private func getProgressColor() -> Color {
        let p = timer.progress
        if p < 0.3 { return .orange }
        else if p < 0.7 { return primaryBlue }
        else { return .green }
    }
    
    private func remainingCompact() -> String {
        let remaining = max(0, timer.targetDuration - timer.currentTime)
        let m = Int(remaining) / 60
        let s = Int(remaining) % 60
        return String(format: "%d:%02d", m, s)
    }
}

    // MARK: - 小型統計卡片（簡潔版）
private struct SimpleStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.title3).foregroundColor(color)
            Text(value).font(.system(size: 20, weight: .bold)).foregroundColor(.primary)
            Text(title).font(.caption).foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
                .shadow(color: color.opacity(0.1), radius: 6, x: 0, y: 3)
        )
    }
}

#Preview("運動中頁面（顯示音場）") {
    let tm = TimerManager()
    tm.selectedSoundscape = .city   // 預設顯示「城市清晨」
    tm.targetDuration = 30 * 60
    tm.currentTime = 12 * 60 + 34
    return RunningTimerView()
        .environment(tm)
}
