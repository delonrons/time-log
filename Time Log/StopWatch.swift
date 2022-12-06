//
//  TimeBreakDown.swift
//  Time Log
//
//  Created by Delon Rons on 19/11/2022.
//

import Foundation

class StopWatch: ObservableObject {
    
    @Published var warmUpTimeElapsedFormatted = "00:00:00"
    @Published var lunchBreakSecondsElapsedFormatted = "00:00:00"
    @Published var percent = 0.0
    @Published var mode: StopWatchMode = .stopped
    @Published var seconds = "00"
    @Published var minutes = "00"
    @Published var hours = "00"
    
    var secondsElapsed: Double = 0
    var completedSecondsElapsed: Double = 0
    var warmUpPauseSecondsElapsed: Double = 0
    var lunchBreakSecondsElapsed: Double = 0
    var timer:Timer? = nil
    
    let timeLogDataManager: TimeLogDataManager =  TimeLogDataManager()
    
    func start() {
        self.saveToUserDefault()
        self.mode = .timing
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.secondsElapsed =  Date().timeIntervalSince(self.fetchUserDefault(.startTime)).rounded()
            self.secondsElapsed += 1
            self.formatTime()
            self.calculatePercentage()

            if self.mode == .paused {
                self.warmUpPauseSecondsElapsed += 1
            }
        }
    }
    
    func stop() -> TimeLog {
        timer?.invalidate()
        timer = nil
        self.mode = .stopped
        self.completedSecondsElapsed = self.secondsElapsed
        self.secondsElapsed = 0
        self.warmUpPauseSecondsElapsed = 0
        self.lunchBreakSecondsElapsed = 0
        self.warmUpTimeElapsedFormatted = "00:00:00"
        self.lunchBreakSecondsElapsedFormatted = "00:00:00"
        self.seconds = "00"
        self.minutes = "00"
        self.hours = "00"
        let timeLogData = TimeLogData(
            startDate: self.fetchUserDefault(.startTime),
            endDate: Date(),
            lunchBreakStart: self.fetchUserDefault(.lunchBreakStart),
            lunchBreakEnd: self.fetchUserDefault(.lunchBreakEnd),
            pausedStart: self.fetchUserDefault(.pausedStart),
            pausedEnd: self.fetchUserDefault(.pausedEnd)
        )
        
        self.removeUserDefault(.lunchBreakStart)
        self.removeUserDefault(.lunchBreakEnd)
        self.removeUserDefault(.pausedStart)
        self.removeUserDefault(.pausedEnd)
        self.removeUserDefault(.startTime)
    
        return TimeLog.getTimeLog(timeLogData: timeLogData, numberOfPackets: 0)
    }
    
    func pause() {
        self.mode = .paused
        saveToUserDefault(.pausedStart)
    }
    
    func luchBreak() {
        self.mode = .lunchbreak
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.formatTime()
            self.calculatePercentage()
            self.lunchBreakSecondsElapsed += 1
        }
        
        saveToUserDefault(.lunchBreakStart)
    }
    
    func formatTime() {
        self.seconds = formatDigit(Int(self.secondsElapsed.truncatingRemainder(dividingBy: 60)))
        self.minutes = formatDigit(Int(self.secondsElapsed / 60) % 60)
        self.hours = formatDigit(Int(self.secondsElapsed / 3600))
        self.warmUpTimeElapsedFormatted = formatTime(self.warmUpPauseSecondsElapsed)
        self.lunchBreakSecondsElapsedFormatted = formatTime(self.lunchBreakSecondsElapsed)
    }
    
    private func saveToUserDefault() {
        switch(self.mode) {
        case .stopped:
            saveToUserDefault(.startTime)
            break
        case .paused:
            saveToUserDefault(.pausedEnd)
            break
        case .lunchbreak:
            saveToUserDefault(.lunchBreakEnd)
            break
        case .timing:
            break
        }
    }
    
    private func saveToUserDefault(_ userDefaultName: UserDefaultNames) {
        UserDefaults.standard.set(Date(), forKey: userDefaultName.rawValue)
    }
    
    private func fetchUserDefault(_ userDefaultName: UserDefaultNames) -> Date {
        UserDefaults.standard.object(forKey: userDefaultName.rawValue) as? Date ?? Date()
    }
    
    private func removeUserDefault(_ userDefaultName: UserDefaultNames) {
        UserDefaults.standard.removeObject(forKey: userDefaultName.rawValue)
    }
    
    private func formatTime(_ seconds: Double) -> String {
        let pauseSeconds = formatDigit(Int(seconds.truncatingRemainder(dividingBy: 60)))
        let pauseMinutes = formatDigit(Int(seconds / 60) % 60)
        let pauseHours = formatDigit(Int(seconds / 3600))
        
        return "\(pauseHours):\(pauseMinutes):\(pauseSeconds)"
    }
    
    private func formatDigit(_ digit: Int) -> String {
        String(format:"%02d", digit)
    }
    
    private func calculatePercentage() {
        self.percent = Double(Double(self.secondsElapsed.truncatingRemainder(dividingBy: 60)) / 60.0)
    }
}

enum StopWatchMode {
    case timing
    case stopped
    case paused
    case lunchbreak
}

private enum UserDefaultNames: String {
    case startTime = "startTime"
    case lunchBreakStart = "lunchBreakStart"
    case lunchBreakEnd = "lunchBreakEnd"
    case pausedStart = "pauseStart"
    case pausedEnd = "pausedEnd"
}
