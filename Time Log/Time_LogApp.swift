//
//  Time_LogApp.swift
//  Time Log
//
//  Created by Delon Rons on 19/11/2022.
//

import SwiftUI

@main
struct Time_LogApp: App {
    let timeLogDataManager: TimeLogDataManager =  TimeLogDataManager()
    @ObservedObject var logData = LogData(logData: [])
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            HomeView(logData: logData)
                .onAppear(perform: {
                    timeLogDataManager.load { timeLogData in
                        logData.logData = timeLogData
                    }
                })
                .onChange(of: scenePhase) { phase in
                    if phase == .inactive {
                        self.timeLogDataManager.save(timeLogs: logData.logData)
                    }
                }
        }
    }
}
