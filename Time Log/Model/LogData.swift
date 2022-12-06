//
//  LogData.swift
//  Time Log
//
//  Created by Delon Rons on 05/12/2022.
//

import SwiftUI

class LogData: ObservableObject {
    @Published var logData: [TimeLog]
    @Published var editId: UUID? = nil
    
    init(logData: [TimeLog]) {
        self.logData = logData
    }
    
    func getEditTimeLogBinding() -> Binding<TimeLog> {
        Binding<TimeLog>(get: {
            self.logData.first(where: { $0.id == self.editId})!
        }, set: { newValue in
            self.logData = self.logData.map { tl in
                if tl.id == self.editId {
                    return newValue
                } else {
                    return tl
                }
            }
        })
    }
}
