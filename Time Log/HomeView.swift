//
//  HomeView.swift
//  Time Log
//
//  Created by Delon Rons on 19/11/2022.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var logData: LogData
    
    var body: some View {
        TabView {
            WorkClockView(timeLogs: $logData.logData)
                .tabItem {
                    Label("Timer", systemImage: "clock.arrow.2.circlepath")
                }
            VStack {
                
                let grouped = Util.groupByMonth(timeLogs: logData.logData)
                let headers = Util.getHeaders(logData: grouped)
                
                NavigationView {
                    List {
                        ForEach(headers, id: \.self) { header in
                            let group:[TimeLog] = grouped[header]!
                            GroupedView(header: header, timeLogs: group, logData: logData)
                            
                        }
                    }
                    .navigationTitle("Summary")
                }
                
            }
            .tabItem {
                Label("Log", systemImage: "scribble")
            }
        }
    }
}

struct GroupedView: View {
    
    var header: String
    var timeLogs: [TimeLog]
    @ObservedObject var logData: LogData
    @State var editLogData: TimeLog = TimeLog(
        date: Date.now,
        total: Time(hour: 0, minute: 0, second: 0),
        lunchBreak: Time(hour: 0, minute: 0, second: 0),
        pause: Time(hour: 0, minute: 0, second: 0),
        numberOfPackets: 0
    )
    @State var id: UUID = UUID()
    @State private var topExpanded = false
    @State var isEdit = false
    
    var body: some View {
        let statistics = Util.getStatistics(logData: timeLogs)
        
        NavigationLink(destination: {
            List {
                ForEach(timeLogs, id: \.id) { log in
                    VStack(spacing: 15) {
                        HStack {
                            Text("\(log.formattedDate)")
                            Spacer()
                            Text("\(log.total.formatedTime)")
                        }
                        .foregroundColor(.accentColor)
                        .bold()
                        
                        HStack {
                            Label("\(log.pause.formatedTime)", systemImage: "pause.circle.fill")
                            Spacer()
                            Label("\(log.lunchBreak.formatedTime)", systemImage: "fork.knife.circle.fill")
                            Spacer()
                            Label("\(log.numberOfPackets)", systemImage: "shippingbox.circle.fill")
                        }
                        .foregroundColor(.accentColor)
                    }
                    .padding([.top, .bottom], 10)
                    .onTapGesture {
                        self.logData.editId = log.id
                        self.editLogData = self.logData.getEditTimeLogBinding().wrappedValue
                        self.isEdit = true
                    }
                }
            }
            .sheet(isPresented: $isEdit, content: {
                NavigationView {
                    EditView(isEdit: true, timeLog: self.$editLogData)
                        .navigationTitle("Edit")
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    isEdit = false
                                }, label: { Text("Cancel").foregroundColor(.red)})
                            }
                            
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    self.logData.getEditTimeLogBinding().wrappedValue = editLogData;
                                    isEdit = false
                                }, label: { Text("Done")})
                            }
                        }
                }
            })
        }, label: {
            VStack(spacing: 10) {
                HStack {
                    Text("\(header)")
                    Spacer()
                    Text("\(statistics.total.formatedTime)")
                }
                .bold()
                .padding([.leading],5)
                HStack {
                    Label("\(statistics.totalPause.formatedTime)", systemImage: "pause.circle.fill")
                    Spacer()
                    Label("\(statistics.totalBreak.formatedTime)", systemImage: "fork.knife.circle.fill")
                    Spacer()
                    Label("\(statistics.totalPackets)", systemImage: "shippingbox.circle.fill")
                }
            }
        })
    }
}

struct HomeView_Previews: PreviewProvider {
    struct StatefulPreviewWrapper: View {
        private var timeLogs: [TimeLog] = [
            TimeLog(
                date: Date.now.addingTimeInterval(-886400000),
                total: Time(hour: 10, minute: 20, second: 30),
                lunchBreak: Time(hour: 0, minute: 10, second: 30),
                pause: Time(hour: 0, minute: 30, second: 00),
                numberOfPackets: 1000
            ),
            TimeLog(
                date: Date.now.addingTimeInterval(-886400000),
                total: Time(hour: 10, minute: 20, second: 30),
                lunchBreak: Time(hour: 0, minute: 10, second: 30),
                pause: Time(hour: 0, minute: 30, second: 00),
                numberOfPackets: 1000
            ),
            TimeLog(
                date: Date(),
                total: Time(hour: 10, minute: 20, second: 30),
                lunchBreak: Time(hour: 0, minute: 10, second: 30),
                pause: Time(hour: 0, minute: 30, second: 00),
                numberOfPackets: 1000
            )
        ]
        
        var body: some View {
            HomeView(logData: LogData(logData: timeLogs))
        }
    }
    
    static var previews: some View {
        StatefulPreviewWrapper()
    }
}
