    //  TimeSliderView.swift
    //  SlowJoggingTimePro

import SwiftUI

struct TimeSliderView: View {
    @Environment(TimerManager.self) private var timerManager
    @State private var sliderValue: Double = 30
    @State private var isDragging = false
    
        /// 緊湊模式：讓整體高度更矮
    var compact: Bool = false
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
    private let quickTimeOptions: [(TimeInterval, String, String)] = [
        (900,  "15分", "輕鬆"),
        (1800, "30分", "剛好"),
        (2700, "45分", "挑戰"),
        (3600, "60分", "充分")
    ]
    
    var body: some View {
        VStack(spacing: vSpacing) {
            timeDisplayCard
            quickTimeGrid
        }
    }
    
        // MARK: - Tunables for compact / regular
    private var numberSize: CGFloat { compact ? 42 : 48 }
    private var vSpacing: CGFloat { compact ? 14 : 20 }
    private var cardPadding: CGFloat { compact ? 16 : 24 }
    private var sliderHeight: CGFloat { compact ? 20 : 24 }
    private var gridSpacing: CGFloat { compact ? 6 : 8 }
    private var quickButtonHeight: CGFloat { compact ? 44 : 50 }
    
        // MARK: - Card
    private var timeDisplayCard: some View {
        VStack(spacing: vSpacing) {
            VStack(spacing: 2) {
                Text("\(Int(sliderValue))")
                    .font(.system(size: numberSize, weight: .bold, design: .rounded))
                    .foregroundColor(primaryBlue)
                Text("分鐘")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 10) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(LinearGradient(colors: [primaryBlue, primaryBlue.opacity(0.7)],
                                                 startPoint: .leading, endPoint: .trailing))
                            .frame(width: getProgressWidth(in: geometry.size.width), height: 8)
                        
                        Circle()
                            .fill(Color.white)
                            .frame(width: 24, height: 24)
                            .shadow(color: primaryBlue.opacity(0.3), radius: 4, x: 0, y: 2)
                            .overlay(Circle().stroke(primaryBlue, lineWidth: 2))
                            .scaleEffect(isDragging ? 1.2 : 1.0)
                            .offset(x: getProgressWidth(in: geometry.size.width) - 12)
                    }
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                let newValue = min(max(1, (value.location.x / geometry.size.width) * 59 + 1), 60)
                                sliderValue = round(newValue)
                                timerManager.targetDuration = sliderValue * 60
                            }
                            .onEnded { _ in isDragging = false }
                    )
                    .onTapGesture { location in
                        let newValue = min(max(1, (location.x / geometry.size.width) * 59 + 1), 60)
                        withAnimation(.easeInOut(duration: 0.2)) {
                            sliderValue = round(newValue)
                            timerManager.targetDuration = sliderValue * 60
                        }
                    }
                }
                .frame(height: sliderHeight)
                
                HStack {
                    Text("1分"); Spacer()
                    Text("15分"); Spacer()
                    Text("30分"); Spacer()
                    Text("45分"); Spacer()
                    Text("60分")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(cardPadding)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: primaryBlue.opacity(0.1), radius: 8, x: 0, y: 2)
        )
        .onAppear {
            sliderValue = timerManager.targetDuration / 60
        }
    }
    
    private var quickTimeGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: gridSpacing), count: 4),
                  spacing: gridSpacing) {
            ForEach(quickTimeOptions, id: \.0) { option in
                quickTimeButton(duration: option.0, time: option.1, label: option.2, height: quickButtonHeight)
            }
        }
    }
    
    private func quickTimeButton(duration: TimeInterval, time: String, label: String, height: CGFloat) -> some View {
        let isSelected = abs(timerManager.targetDuration - duration) < 1
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                timerManager.targetDuration = duration
                sliderValue = duration / 60
            }
        } label: {
            VStack(spacing: 4) {
                Text(time).font(.system(.subheadline, weight: .semibold))
                Text(label).font(.caption).opacity(0.7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: height)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? primaryBlue.opacity(0.1) : Color.gray.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? primaryBlue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? primaryBlue : .primary)
        }
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func getProgressWidth(in totalWidth: CGFloat) -> CGFloat {
        CGFloat((sliderValue - 1) / 59) * totalWidth
    }
}

#Preview("時間滑軌") {
    TimeSliderView(compact: true)
        .environment(TimerManager())
        .padding()
}
