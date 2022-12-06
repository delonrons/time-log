//
//  TimeLogDataManager.swift
//  Time Log
//
//  Created by Delon Rons on 22/11/2022.
//

import Foundation

struct TimeLogDataManager {
    func load(completion: @escaping ([TimeLog]) -> Void) {
        DispatchQueue.global(qos: .background).async {
            if FileManager.default.fileExists(atPath: Self.fileURL.path) == false {
                let bundledProjectsURL = Bundle.main.url(forResource: "time-log", withExtension: "json")!
                try! FileManager.default.copyItem(at: bundledProjectsURL, to: Self.fileURL)
            }
        }
        
        guard let data = try? Data(contentsOf: Self.fileURL) else {
            return
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        guard let timeLogs = try? decoder.decode([TimeLog].self, from: data) else {
            fatalError("Can't decode saved renovation project data.")
        }
        
        DispatchQueue.main.async {
            completion(timeLogs)
        }
    }
    
    func save(timeLogs: [TimeLog]) {
        DispatchQueue.global(qos: .background).async {
            let encoder = JSONEncoder()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            
            guard let timeLogData = try? encoder.encode(timeLogs) else { fatalError("Error encoding data") }
            do {
                let outFile = Self.fileURL
                try timeLogData.write(to: outFile)
            } catch {
                fatalError("Can't write to file.")
            }
        }
    }

    
    private static var documentsFolder: URL {
        do {
            return try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        } catch {
            fatalError("Can't find documents directory.")
        }
    }
    
    private static var fileURL: URL {
        return documentsFolder.appendingPathComponent("time-log.json")
    }
}
