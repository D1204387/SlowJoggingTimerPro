//
//  TimerManager.swift
//  SlowJoggingTimePro
//
//  Created by YiJou  on 2025/8/23.
   
import Foundation
import AVFoundation
import UIKit

@Observable
@MainActor
class TimerManager: NSObject {
    
        // MARK: - State
    var currentTime: TimeInterval = 0
    var targetDuration: TimeInterval = 1800
    var selectedMusic: MusicType = .lightMusic
    var selectedSoundscape: SoundscapeKind = .light
    
    var isRunning = false
    var isPaused  = false
    
        // 舊資料相容：不自動遞增
    var steps = 0
    var records: [JoggingRecord] = []
    
        // UI：完成動畫旗標
    var showCompletionAnimation = false
    
        // MARK: - Background Music
    private var musicPlayer: AVAudioPlayer?
    private var fadeTask: Task<Void, Never>?
    
        // MARK: - Metronome (AVAudioPlayer, dual players)
    var metronomeEnabled: Bool = true         // 依你的需求：常駐開啟
    var metronomeBPM: Int = 180
    private var metronomeTask: Task<Void, Never>?
    private var clickPlayerA: AVAudioPlayer?
    private var clickPlayerB: AVAudioPlayer?
    private var useAltPlayer = false
    
        // MARK: - Completion Chime
    private var completionPlayer: AVAudioPlayer?
    private var chimeFadeTask: Task<Void, Never>?
    
        // MARK: - Lifecycle
    override init() {
        super.init()
        loadRecords()
        configureAudioSession()
        observeInterruption()
        preloadCompletionChime()    // 預先解碼，降低首次延遲
    }
    
    deinit {
            // selector 版註冊 → 解註冊時移除 self
        NotificationCenter.default.removeObserver(self,
                                                  name: AVAudioSession.interruptionNotification,
                                                  object: nil)
    }
    
        // MARK: - Derived
    var progress: Double {
        guard targetDuration > 0 else { return 0 }
        return min(currentTime / targetDuration, 1.0)
    }
    
    var formattedTime: String {
        let h = Int(currentTime) / 3600
        let m = Int(currentTime) % 3600 / 60
        let s = Int(currentTime) % 60
        return h > 0 ? String(format: "%d:%02d:%02d", h, m, s)
        : String(format: "%d:%02d", m, s)
    }
    
    var remainingTime: String {
        let r = max(0, targetDuration - currentTime)
        let m = Int(r) / 60
        let s = Int(r) % 60
        return String(format: "剩餘 %d:%02d", m, s)
    }
    
        // MARK: - Controls
    func startTimer() {
        if currentTime >= targetDuration && targetDuration > 0 { resetTimer() }
        if isRunning { return }
        
        isRunning = true
        isPaused  = false
        
        Task { await runTimer() }
        
        startBackgroundAudio()
        startMetronomeIfNeeded()
    }
    
    func pauseTimer() {
        isRunning = false
        isPaused  = true
        pauseBackgroundAudio()
        stopMetronome()
    }
    
    func resumeTimer() {
        guard !isRunning else { return }
        isRunning = true
        isPaused  = false
        
        Task { await runTimer() }
        
        resumeBackgroundAudio()
        startMetronomeIfNeeded()
    }
    
    func stopTimer() {
        isRunning = false
        isPaused  = false
        
        if let record = createRecord() { addRecord(record) }
        
        stopBackgroundAudio()
        stopMetronome()
        stopCompletionChime()
        
        resetTimer()
    }
    
        // MARK: - Soundscape
    func updateSoundscape(_ kind: SoundscapeKind) {
        selectedSoundscape = kind
            // 正在運行中就切換背景音（會先停掉再淡入新音檔）
        if isRunning && !isPaused {
            startBackgroundAudio()
        }
    }

    
    
        // MARK: - Core loop
    private func runTimer() async {
        while isRunning {
            do {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                if isRunning {
                    currentTime += 1
                        // steps += Int.random(in: 2...4) // ❌ 已停用隨機步數
                    if currentTime >= targetDuration && targetDuration > 0 {
                        await completeTimer()
                        break
                    }
                }
            } catch { break }
        }
    }
    
    private func completeTimer() async {
        isRunning = false
        
            // 停節拍器，觸覺成功回饋
        stopMetronome()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        
            // 背景音樂稍降，再播放完成 chime（6 秒也 OK，後段自動淡出）
        fade(to: 0.15, duration: 0.25)
        playCompletionChime(audibleFor: 2.5, fadeOut: 0.8)
        
            // 立刻顯示完成動畫（不阻塞等待音效）
        showCompletionAnimation = true
        
            // 建立並保存記錄
        if let record = createRecord() { addRecord(record) }
        
            // 稍後關掉背景音樂（避免切太硬）
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            stopBackgroundAudio()
        }
    }
    
    func dismissCompletionAnimationAndReset() {
        showCompletionAnimation = false
        stopCompletionChime()
        resetAfterCompletion()
    }
    
    private func resetTimer() {
        isRunning = false
        isPaused  = false
        currentTime = 0
        steps = 0
        stopBackgroundAudio()
        stopMetronome()
    }
    
    func resetAfterCompletion() {
        currentTime = 0
        steps = 0
        isRunning = false
        isPaused  = false
    }
    
        // MARK: - Records
    private func createRecord() -> JoggingRecord? {
        guard currentTime >= 60 else { return nil }
        let calories = Int(currentTime * 0.12)
        return JoggingRecord(
            duration: currentTime,
            targetDuration: targetDuration,
            date: Date(),
            musicType: selectedMusic.rawValue,
            steps: steps,
            calories: calories
        )
    }
    
    private func addRecord(_ r: JoggingRecord) {
        records.insert(r, at: 0)
        saveRecords()
    }
    
    private func saveRecords() {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: "JoggingRecords")
        }
    }
    
    private func loadRecords() {
        if let data = UserDefaults.standard.data(forKey: "JoggingRecords"),
           let arr  = try? JSONDecoder().decode([JoggingRecord].self, from: data) {
            records = arr
        }
    }
    
        // MARK: - Settings helpers
    func setTargetMinutes(_ minutes: Int) { targetDuration = TimeInterval(minutes * 60) }
    var targetMinutes: Int { Int(targetDuration / 60) }
    func updateMusic(_ musicType: MusicType) { selectedMusic = musicType }
    func updateTargetDuration(_ minutes: Double) { targetDuration = minutes * 60 }
    func clearAllRecords() { records.removeAll(); saveRecords() }
    
        // MARK: - Metronome (AVAudioPlayer)
    func setMetronomeEnabled(_ enabled: Bool) {
        metronomeEnabled = enabled
        if isRunning && !isPaused {
            enabled ? startMetronomeIfNeeded() : stopMetronome()
        }
    }
    
    func setMetronomePreset(_ bpm: Int) {
        metronomeBPM = bpm
        if isRunning && !isPaused && metronomeEnabled {
            startMetronomeIfNeeded()
        }
    }
    
    private func startMetronomeIfNeeded() {
        guard metronomeEnabled, metronomeBPM > 0 else { return }
        startMetronome()
    }
    
    private func startMetronome() {
        stopMetronome()
        prepareClickPlayers()
        
        let bpm = Double(metronomeBPM)
        let interval = UInt64(60.0 / bpm * 1_000_000_000)
        
        metronomeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            while !Task.isCancelled {
                if self.isRunning && !self.isPaused && self.metronomeEnabled {
                    self.playMetronomeClick()
                }
                try? await Task.sleep(nanoseconds: interval)
            }
        }
    }
    
    private func stopMetronome() {
        metronomeTask?.cancel()
        metronomeTask = nil
        clickPlayerA?.stop()
        clickPlayerB?.stop()
        clickPlayerA = nil
        clickPlayerB = nil
        useAltPlayer = false
    }
    
    private func prepareClickPlayers() {
        guard clickPlayerA == nil || clickPlayerB == nil else { return }
        guard let url = urlForResource("metronome_click", ext: "wav") else {
            print("⚠️ 找不到 metronome_click.wav")
            return
        }
        do {
            let a = try AVAudioPlayer(contentsOf: url)
            let b = try AVAudioPlayer(contentsOf: url)
            a.volume = 1.0; b.volume = 1.0
            a.prepareToPlay(); b.prepareToPlay()
            clickPlayerA = a
            clickPlayerB = b
        } catch {
            print("⚠️ 無法載入 metronome_click.wav：\(error)")
        }
    }
    
    private func playMetronomeClick() {
        let player = (useAltPlayer ? clickPlayerB : clickPlayerA)
        player?.currentTime = 0
        player?.play()
        useAltPlayer.toggle()
    }
    
        // MARK: - Background Music
    private func startBackgroundAudio() {
        stopBackgroundAudio()
        switch selectedSoundscape{
        case .light:
            playLoop(named: "light_music", fileExtension: "mp3", volume: 0.6)
        case .nature:
            playLoop(named: "nature_ambient", fileExtension: "mp3", volume: 0.6)
        case .city:
            playLoop(named: "city_lofi", fileExtension: "mp3", volume: 0.6)
        case .focus:
            playLoop(named: "ambient_pulse", fileExtension: "mp3", volume: 0.6)
        }
    }
    
    private func pauseBackgroundAudio() {
        fade(to: 0.0, duration: 0.25) { [weak self] in
            self?.musicPlayer?.pause()
        }
    }
    
    private func resumeBackgroundAudio() {
        guard let player = musicPlayer else {
            startBackgroundAudio()
            return
        }
        try? AVAudioSession.sharedInstance().setActive(true, options: [])
        player.play()
        fade(to: 0.6, duration: 0.25)
    }
    
    private func stopBackgroundAudio() {
        fadeTask?.cancel()
        musicPlayer?.stop()
        musicPlayer = nil
    }
    
        // MARK: - Completion Chime
    private func preloadCompletionChime() {
        if completionPlayer == nil,
           let url = firstExistingResource([("completion_chime","m4a"),
                                            ("completion_chime","mp3"),
                                            ("completion_chime","wav")]) {
            completionPlayer = try? AVAudioPlayer(contentsOf: url)
            completionPlayer?.prepareToPlay()
            completionPlayer?.volume = 1.0
        }
    }
    
    private func playCompletionChime(audibleFor seconds: TimeInterval = 2.5, fadeOut: TimeInterval = 0.8) {
        if completionPlayer == nil {
            preloadCompletionChime()
        }
        guard let p = completionPlayer else { return }
        
        p.currentTime = 0
        p.volume = 1.0
        p.play()
        
        chimeFadeTask?.cancel()
        chimeFadeTask = Task { @MainActor in
                // 前 N 秒維持音量
            try? await Task.sleep(nanoseconds: UInt64(max(0, seconds) * 1_000_000_000))
                // 淡出
            let steps = max(1, Int(fadeOut / 0.016))
            let start = p.volume
            for i in 1...steps {
                if Task.isCancelled { return }
                let t = Float(i) / Float(steps)
                p.volume = start * (1 - t)
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
            p.stop()
            p.currentTime = 0
            p.volume = 1.0
        }
    }
    
    private func stopCompletionChime() {
        chimeFadeTask?.cancel()
        completionPlayer?.stop()
        completionPlayer?.currentTime = 0
    }
    
        // MARK: - Helpers (resources & fade)
    private func urlForResource(_ name: String, ext: String) -> URL? {
        let b = Bundle.main
        if let u = b.url(forResource: name, withExtension: ext) { return u }                         // 黃資料夾/單檔
        if let u = b.url(forResource: name, withExtension: ext, subdirectory: "Audio") { return u } // 藍資料夾
        return nil
    }
    
    private func firstExistingResource(_ candidates: [(String, String)]) -> URL? {
        for (name, ext) in candidates {
            if let u = urlForResource(name, ext: ext) { return u }
        }
        return nil
    }
    
    private func playLoop(named: String, fileExtension: String, volume: Float) {
        guard let url = urlForResource(named, ext: fileExtension) else {
            print("⚠️ 找不到音檔：\(named).\(fileExtension)")
            return
        }
        do {
            let p = try AVAudioPlayer(contentsOf: url)
            p.numberOfLoops = -1
            p.volume = 0
            p.prepareToPlay()
            musicPlayer = p
            p.play()
            fade(to: volume, duration: 0.5)
        } catch {
            print("⚠️ 無法播放：\(error)")
        }
    }
    
        /// 在 MainActor 上淡入淡出（Swift 6：completion 標註 @MainActor @Sendable）
    private func fade(
        to target: Float,
        duration: TimeInterval,
        completion: (@MainActor @Sendable () -> Void)? = nil
    ) {
        fadeTask?.cancel()
        fadeTask = Task { @MainActor in
            guard let player = musicPlayer else { completion?(); return }
            let start = player.volume
            if duration <= 0 {
                player.volume = target
                completion?()
                return
            }
            let steps = max(1, Int(duration / 0.016)) // 約 60fps
            for i in 1...steps {
                if Task.isCancelled { return }
                let t = Float(i) / Float(steps)
                player.volume = start + (target - start) * t
                try? await Task.sleep(nanoseconds: 16_000_000)
            }
            player.volume = target
            completion?()
        }
    }
    
        // MARK: - Audio Session / Interruptions
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback,
                                                            mode: .default,
                                                            options: [.duckOthers])
            try AVAudioSession.sharedInstance().setActive(true, options: [])
        } catch {
            print("⚠️ AudioSession 設定失敗：\(error)")
        }
    }
    
    private func observeInterruption() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }
    
    @objc private func handleInterruption(_ note: Notification) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            guard let info = note.userInfo,
                  let raw = info[AVAudioSessionInterruptionTypeKey] as? UInt,
                  let type = AVAudioSession.InterruptionType(rawValue: raw) else { return }
            
            switch type {
            case .began:
                self.musicPlayer?.pause()
                self.clickPlayerA?.pause()
                self.clickPlayerB?.pause()
                self.stopCompletionChime()
            case .ended:
                if self.isRunning && !self.isPaused {
                    try? AVAudioSession.sharedInstance().setActive(true, options: [])
                    self.musicPlayer?.play()
                    self.startMetronomeIfNeeded()
                }
            @unknown default:
                break
            }
        }
    }
}
