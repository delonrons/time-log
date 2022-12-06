//
//  TimeLog.swift
//  Time Log
//
//  Created by Delon Rons on 22/11/2022.
//

import Foundation

struct TimeLog: Codable, Identifiable {
    var date: Date
    var total: Time
    var lunchBreak: Time
    var pause: Time
    var numberOfPackets: Int
    let id = UUID()
}

struct Time: Codable {
    var hour: Int32
    var minute: Int32
    var second: Int32
}

struct TimeLogData {
    let startDate: Date
    let endDate: Date
    let lunchBreakStart: Date
    let lunchBreakEnd: Date
    let pausedStart: Date
    let pausedEnd: Date
}
