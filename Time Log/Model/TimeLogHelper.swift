//
//  TimeLogHelper.swift
//  Time Log
//
//  Created by Delon Rons on 22/11/2022.
//

import Foundation

extension TimeLog {
    
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE MMM d, YYYY"
        
        return dateFormatter.string(from: date)
    }
    
    static func getTimeLog(timeLogData: TimeLogData, numberOfPackets: Int) -> TimeLog {
        let totalTime = Self.calculateTime(start: timeLogData.startDate, end: timeLogData.endDate)
        let breakTime = Self.calculateTime(start: timeLogData.lunchBreakStart, end: timeLogData.lunchBreakEnd)
        let pauseTime = Self.calculateTime(start: timeLogData.pausedStart, end:timeLogData.pausedEnd)
        
        return TimeLog(date: timeLogData.startDate, total: totalTime, lunchBreak: breakTime, pause: pauseTime, numberOfPackets: numberOfPackets)
    }
    
    static func calculateTime(start: Date, end: Date) -> Time {
        let totalSeconds =  end.timeIntervalSince(start).rounded()
        
        return calculateTime(elapsedSeconds: totalSeconds)
    }
    
    static func calculateTime(elapsedSeconds: Double) -> Time {
        let seconds = Int32(elapsedSeconds.truncatingRemainder(dividingBy: 60))
        let minutes = Int32(elapsedSeconds / 60) % 60
        let hours = Int32(elapsedSeconds / 3600)
        
        return Time(hour: hours, minute: minutes, second: seconds)
    }
}


extension Time {
    
    var formatedTime: String {
        return "\(formatDigit(hour)):\(formatDigit(minute))"
    }
    
    private func formatDigit(_ digit: Int32) -> String {
        String(format:"%02d", digit)
    }
}

struct Statistics {
    var total: Time
    var totalBreak: Time
    var totalPause: Time
    var totalPackets: Int64
}


struct Util {
    static func groupByMonth(timeLogs: [TimeLog]) -> [String: [TimeLog]] {
        Dictionary(grouping: timeLogs, by: { formattedDate($0.date) })
    }
    
    static func getHeaders(logData: [String: [TimeLog]]) -> [String] {
        logData.map({ $0.key })
    }
    
    static func getStatistics(logData: [TimeLog]) -> Statistics {
        
        let totalForMonth = logData.reduce(0, { accu, log in
            accu + toSeconds(log.total)
        })
        
        let breakForMonth = logData.reduce(0, { accu, log in
            accu + toSeconds(log.lunchBreak)
        })
        
        let pauseForMonth = logData.reduce(0, { accu, log in
            accu + toSeconds(log.pause)
        })
        
        let packetsForMonth = logData.reduce(0, { accu, log in
            accu + Int64(log.numberOfPackets)
        })
        
        return Statistics(
            total: TimeLog.calculateTime(elapsedSeconds: totalForMonth),
            totalBreak: TimeLog.calculateTime(elapsedSeconds: breakForMonth),
            totalPause: TimeLog.calculateTime(elapsedSeconds: pauseForMonth),
            totalPackets: packetsForMonth
        )
    }
    
    static func toSeconds(_ time: Time) -> Double {
        Double(time.hour * 3600) + Double(time.minute * 60) + Double(time.second)
    }
    
    static func formattedDate(_ date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM, YYYY"
        
        return dateFormatter.string(from: date)
    }
}
