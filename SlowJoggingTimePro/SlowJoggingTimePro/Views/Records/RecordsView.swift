//
//  RecordsView.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
//

import SwiftUI
import Charts   // iOS 16+

struct RecordsView: View {
    @Environment(TimerManager.self) private var timer
    
    private let primaryBlue = Color(red: 0.3, green: 0.6, blue: 1.0)
    
        // 近 7 天（含今天）的起訖
    private var last7StartOfDay: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: -6, to: today)! // 含今天，共 7 天
    }
    private var last7EndOfDay: Date {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return cal.date(byAdding: .day, value: 1, to: today)! // 明日 00:00 做上界
    }
    
        // 近 7 天的所有記錄
    private var records7: [JoggingRecord] {
        timer.records.filter { $0.date >= last7StartOfDay && $0.date < last7EndOfDay }
    }
    
        // 近 7 天的每日統計（即使沒運動也保留 0）
    private var dayStats: [DayStat] {
        let cal = Calendar.current
        var buckets: [Date: [JoggingRecord]] = [:]
        for i in 0..<7 {
            let d = cal.date(byAdding: .day, value: i, to: last7StartOfDay)!
            buckets[d] = []
        }
        for r in records7 {
            let key = cal.startOfDay(for: r.date)
            if buckets[key] != nil { buckets[key]?.append(r) }
        }
        return buckets.keys.sorted().map { day in
            let recs = buckets[day] ?? []
            let totalDur = recs.reduce(0.0) { $0 + $1.duration } / 60.0 // 分
            let totalTarget = recs.reduce(0.0) { $0 + $1.targetDuration } / 60.0
            let met = totalTarget > 0 ? (totalDur >= totalTarget) : false
            return DayStat(day: day, minutes: totalDur, goalMet: met)
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BeautifulBackground().ignoresSafeArea()
                
                if timer.records.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 14) {
                            
                                // 摘要（近 7 天）
                            Summary7View(records: records7)
                            
                                // 七日圖表
                            SevenDayChartView(dayStats: dayStats,
                                              targetMinutes: timer.targetDuration / 60)
                            
                                // ---- 運動詳情（標題在清單上方）----
                            detailHeader
                            
                            ForEach(Array(records7.sorted(by: { $0.date > $1.date }).enumerated()),
                                    id: \.offset) { pair in
                                let rec = pair.element
                                RecordRow(record: rec)
                            }
                            
                            Spacer(minLength: 24)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .padding(.bottom, 8)
                    }
                }
            }
            .navigationTitle("記錄")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !timer.records.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
//                        Button("清除") { timer.clearAllRecords() }
                    }
                }
            }
        }
    }
    
        // MARK: - 「運動詳情」標題（在清單的上方）
    private var detailHeader: some View {
        HStack {
            Label("運動詳情", systemImage: "list.bullet.rectangle")
                .font(.headline)
                .foregroundColor(.primary)
            Spacer()
            Text("近 7 天 • \(records7.count) 筆")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.92))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.6), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.doc.horizontal")
                .font(.system(size: 42))
                .foregroundColor(primaryBlue.opacity(0.7))
            Text("暫無記錄")
                .font(.headline)
                .foregroundColor(.primary)
            Text("完成一次超慢跑後，這裡會顯示你的近 7 天統計與詳情。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
}

    // MARK: - 近 7 天摘要卡

private struct Summary7View: View {
    let records: [JoggingRecord]
    
    private var totalRuns: Int { records.count }
    
    private var totalMinutes: Int {
        Int(records.reduce(0.0) { $0 + $1.duration } / 60.0)
    }
    
    private var averageCompletion: Int {
        guard !records.isEmpty else { return 0 }
        let sum = records.reduce(0.0) { acc, r in
            guard r.targetDuration > 0 else { return acc }
            return acc + min(r.duration / r.targetDuration, 1.0)
        }
        return Int((sum / Double(records.count)) * 100)
    }
    
    private var goalMetCount: Int {
        records.filter { $0.targetDuration > 0 && $0.duration >= $0.targetDuration }.count
    }
    
    private func compactTime(_ minutes: Int) -> String {
        let h = minutes / 60
        let m = minutes % 60
        return h > 0 ? "\(h)小時\(m)分" : "\(m)分"
    }
    private var data: [SummaryDatum] {
        [
            .init(icon: "figure.walk",         title: "次數",   value: "\(totalRuns)"),
            .init(icon: "timer",               title: "時長",   value: compactTime(totalMinutes)),
            .init(icon: "target",              title: "達標",   value: "\(goalMetCount) 次"),
            .init(icon: "checkmark.seal.fill", title: "完成度", value: "\(averageCompletion)%")
        ]
    }
    
    private let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Label("近 7 天摘要", systemImage: "chart.pie.fill")
                    .foregroundColor(.primary)
                    .font(.headline)
                Spacer()
            }
            
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(data) { item in
                    SummaryPill(icon: item.icon, title: item.title, value: item.value)
                }
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.96))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.7), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }
}

private struct SummaryDatum: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let value: String
}

private struct SummaryPill: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.caption).foregroundColor(.secondary)
                Text(title).font(.caption).foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            Text(value)
                .font(.system(size: 20, weight: .semibold, design: .rounded))
                .monospacedDigit()
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 84)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Color.white)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.12), lineWidth: 1))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

    // MARK: - 七日圖表

private struct SevenDayChartView: View {
    let dayStats: [DayStat]           // 7 筆，日期已排序
    let targetMinutes: Double         // 畫目標線（使用當前設定）
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Label("近 7 天", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            
            Chart {
                    // 柱狀圖
                ForEach(dayStats) { stat in
                    BarMark(
                        x: .value("日期", stat.day),
                        y: .value("分鐘", stat.minutes)
                    )
                    .foregroundStyle(stat.goalMet ? .green : .orange)
                    .cornerRadius(4)
                }
                    // 目標線
                if targetMinutes > 0 {
                    RuleMark(y: .value("目標", targetMinutes))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                        .foregroundStyle(.blue.opacity(0.6))
                }
            }
            .chartXAxis {
                AxisMarks(values: dayStats.map(\.day)) {
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartYScale(domain: 0...(max(maxY, targetMinutes)))
            .frame(height: 180)
            .padding(.top, 6)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.95))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 6)
        )
    }
    
    private var maxY: Double {
        max(dayStats.map(\.minutes).max() ?? 0, 30)
    }
}

    // MARK: - 單列（不含步數/卡路里）

private struct RecordRow: View {
    let record: JoggingRecord
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
                // 日期區
            VStack(alignment: .leading, spacing: 2) {
                Text(dayString(record.date)).font(.headline)
                Text(timeString(record.date)).font(.caption).foregroundColor(.secondary)
            }
            .frame(width: 58, alignment: .leading)
            
                // 內容
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Label(durationString(record.duration), systemImage: "timer")
                        .font(.subheadline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "chart.pie.fill").font(.caption)
                        Text("\(completionPercent(record))%").font(.subheadline)
                    }
                    .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Circle()
                        .fill(isGoalMet(record) ? Color.green : Color.orange)
                        .frame(width: 8, height: 8)
                }
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            )
        }
    }
    
        // Helpers
    private func durationString(_ seconds: TimeInterval) -> String {
        let total = Int(seconds)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%d分%02d", m, s)
    }
    private func completionPercent(_ rec: JoggingRecord) -> Int {
        guard rec.targetDuration > 0 else { return 0 }
        return Int(min(rec.duration / rec.targetDuration, 1.0) * 100)
    }
    private func isGoalMet(_ rec: JoggingRecord) -> Bool {
        rec.targetDuration > 0 && rec.duration >= rec.targetDuration
    }
    private func dayString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "MM/dd"; return f.string(from: date)
    }
    private func timeString(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "HH:mm"; return f.string(from: date)
    }
}

    // MARK: - 模型

private struct DayStat: Identifiable {
    let id = UUID()
    let day: Date         // 當天 00:00
    let minutes: Double   // 當天總分鐘
    let goalMet: Bool     // 當天總時長是否達到當天所有目標總和
}

#Preview("記錄頁（近 7 天）") {
    let tm = TimerManager()
        // 造幾筆近 7 天假資料
    let cal = Calendar.current
    let today0 = cal.startOfDay(for: Date())
    func d(_ daysAgo: Int, _ minutes: Int, _ target: Int) -> JoggingRecord {
        JoggingRecord(
            duration: TimeInterval(minutes * 60),
            targetDuration: TimeInterval(target * 60),
            date: cal.date(byAdding: .day, value: -daysAgo, to: today0)!.addingTimeInterval(60*Double(Int.random(in: 0...60))),
            musicType: MusicType.lightMusic.rawValue,
            steps: 0, calories: 0
        )
    }
    tm.records = [
        d(0, 32, 30), d(1, 10, 30), d(2, 35, 30),
        d(3, 18, 30), d(4, 45, 30), d(5, 0, 30),
        d(6, 25, 30), d(6, 10, 30)
    ].shuffled()
    return RecordsView().environment(tm)
}
