SlowJoggingTimePro

一個為「超慢跑」設計的 時間型 跑步 App。
選時間、選音場、按開始——舒服地把今天跑完就好。

核心理念：簡單、愉悅、可持續。
刻意不顯示配速/卡路里/步數，減少壓力，專注完成。

目錄

功能

畫面預覽

技術重點

需求與相容性

快速開始

音訊與資源放置

資料儲存

專案結構

開發說明

常見問題（FAQ）

路線圖

授權

功能

🟢 首頁（無壓力啟動）

今日小提示（7 則，App 啟動時隨機顯示）

自訂時間滑軌（1–60 分）＋快捷 15/30/45/60 分

音場選擇（輕音樂／自然音／城市清晨／專注氛圍）

底部主行動（CTA）固定於標籤列之上，拇指好按

🟣 運動中

大型圓形進度環、已用/剩餘時間、完成百分比

顯示目前音場（emoji + 標題｜副標）

節拍器恆開（建議 90/180 BPM），不拉伸音樂

暫停／繼續／結束

🟡 完成動畫

全螢幕動畫 + 溫和完成音（建議 3–6 秒「弦樂落點」）

一鍵完成返回首頁

🔵 記錄

近 7 天摘要：次數、總時長、達標次數、平均完成度

近 7 天圖表（Swift Charts）：柱狀＋目標線

詳情列表：日期、時長、完成度

一鍵清除（開發期間方便測試）

畫面預覽

將以下檔名替換為你的實際截圖：Screenshots/home.png、Screenshots/running.png、Screenshots/records.png

首頁


運動中


記錄（近 7 天）


技術重點

狀態管理：使用 Observation（@Observable + @Environment(TimerManager.self)）單一資料源，避免混用 @EnvironmentObject/@Published。

UI/動畫：SwiftUI、玻璃卡片、圓形進度、動態背景（隨機 offset 僅計算一次，避免重繪跳動）。

音訊：

AVAudioSession(.playback) + AVAudioPlayer 迴圈播放背景音場；

節拍器改為播放短 click 音檔（不做時長拉伸）；

支援淡入淡出、音訊中斷（來電/控制中心）恢復。

圖表：Swift Charts（近 7 天統計）。

資料：UserDefaults + JSON 儲存 [JoggingRecord]；設定類使用 @AppStorage（音場、上次目標分鐘、BPM）。

需求與相容性

Xcode：15 以上（建議最新）

iOS：17+（因使用 Observation @Observable）

語言：Swift 5.9+

框架：SwiftUI、AVFoundation、Charts

若需支援 iOS 16，需將 @Observable 改回 ObservableObject + @Published，並調整注入方式。

快速開始

Clone 專案 並用 Xcode 打開 .xcodeproj 或 .xcworkspace。

加入音檔（見下一節），確認已被包含在 Build Phases → Copy Bundle Resources。

在 Signing & Capabilities 勾選：

Background Modes → Audio, AirPlay, and Picture in Picture

直接在模擬器或實機 Run。

音訊與資源放置

音場檔名（放在 Audio/）

音場（UI）	檔名
輕音樂｜舒緩旋律	light_music.mp3
自然音｜森林/海浪	nature_ambient.mp3
城市清晨｜Lo-fi 低節奏	city_lofi.mp3
專注氛圍｜環境脈衝	ambient_pulse.mp3

完成音建議

finish_chord.m4a（3–6 秒、收束感和弦或鐘聲），置於 Audio/。

可用 黃資料夾（Group） 或 藍資料夾（Folder Reference） 加入。
專案內已提供 urlForResource，可同時尋找兩種加入方式的路徑。

資料儲存

運動記錄：UserDefaults（key：JoggingRecords）

透過 JSONEncoder/Decoder 編碼/解碼 [JoggingRecord]

檔案位於 App 沙盒中的 Library/Preferences/<BundleID>.plist

使用者設定（@AppStorage）：

已選音場：SelectedSoundscapeKind

目標分鐘數：TargetMinutes

BPM：MetronomeBPM

MVP 階段使用 UserDefaults；若要長期擴充與查詢，建議遷移至 SwiftData（見路線圖
）。

專案結構
SlowJoggingTimePro/
├─ App/
│  └─ ContentView.swift
├─ Core/
│  ├─ TimerManager.swift              // @Observable 單一狀態源（計時、音訊、記錄）
│  └─ Models/
│     └─ JoggingRecord.swift
├─ Views/
│  ├─ HomeView.swift
│  ├─ RunningTimerView.swift
│  ├─ CompletionAnimationView.swift
│  ├─ RecordsView.swift               // 近 7 天摘要 + 圖表 + 詳情
│  ├─ Components/
│  │  ├─ TimeSliderView.swift
│  │  ├─ MusicSelectionView.swift     // 舊版音樂選擇
│  │  ├─ SoundscapePickerView.swift   // 新版音場選擇（建議使用）
│  │  └─ Shared/
│  │     └─ RunTips.swift             // 今日小提示（7 則）
│  └─ Root/
│     └─ RunRootView.swift            // 在一個 Tab 內切換 Home/Running
├─ Audio/                              // 放置 mp3/m4a 音檔
└─ README.md


你可以在 HomeView 替換：

// 舊
GlassCard { MusicSelectionView() }
// 新（建議）
GlassCard { SoundscapePickerView() }

開發說明
狀態注入（Observation）
@main
struct AppMain: App {
    @State private var timerManager = TimerManager()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(timerManager) // 單一資料源供整個 App 使用
        }
    }
}

音場更新（不影響計時）
// SoundscapePickerView 的按鈕動作
selectedRaw = kind.rawValue
timerManager.updateSoundscape(kind)   // 正在運行時會做淡入切換

完成動畫觸發
// TimerManager.completeTimer()
showCompletionAnimation = true

// RunningTimerView 監聽
.onChange(of: timer.showCompletionAnimation) { _, newValue in
    if newValue { showCompletionView = true; timer.showCompletionAnimation = false }
}

調試工具（選配）
#if DEBUG
func debugExportRecordsToDocuments() { /* 將紀錄輸出為 Documents/records.json */ }
#endif

常見問題（FAQ）

Q1. 背景音樂播不出來？

檢查檔名與副檔名是否完全一致（區分大小寫）。

確認檔案已在 Build Phases → Copy Bundle Resources。

Signing & Capabilities 勾選 Background Modes → Audio…。

模擬器音量/靜音開關、macOS 音量是否正常。

Q2. 我想讓音樂跟著 BPM 變 180/90，可以嗎？

不建議拉伸音樂（音質會變差）。目前設計是：音樂只當柔和背景，節拍器提供穩定 90/180 拍點。

Q3. 為什麼沒有配速/卡路里/步數？

刻意簡化，降低焦慮；以「完成時間」為唯一目標。若日後有需求，可在設定中開啟進階資料。

Q4. 模擬器怎麼查看 UserDefaults 的檔案？

open "$(xcrun simctl get_app_container booted <你的BundleID> data)/Library/Preferences"


<你的BundleID> 例：com.zoe.SlowJoggingTimePro

路線圖

🔁 SwiftData：改用資料庫模型，支援查詢、分頁、iCloud（選配）

⏰ 通知提醒：每日固定時間提醒、連續天數（streak）

🎧 音場包：新增季節主題與完成音主題

🖼️ 分享卡：生成完成卡片，分享至社群

❤️ HealthKit（選配）：以「運動時間」為主進行寫入

授權

程式碼：請依你課程/專題要求設定（MIT / Apache-2.0 / All rights reserved…）。

音樂/音效：請確認來源授權可用於 App；將授權來源與條款附註於 Audio/README.md 或此 README 的附錄。

附錄：音場命名建議（UI 文案）

輕音樂｜舒緩旋律

自然音｜森林/海浪

城市清晨｜Lo-fi 低節奏

專注氛圍｜環境脈衝

完成音：弦樂落點（3–6 秒）
