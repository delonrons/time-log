//
//  WorkClockView.swift
//  Time Log
//
//  Created by Delon Rons on 19/11/2022.
//

import SwiftUI

struct WorkClockView: View {
    @Binding var timeLogs: [TimeLog]
    @ObservedObject var stopWatch = StopWatch()
    @State private var percent = 0.0;
    @State private var showStart = true;
    @State private var showPause = false;
    @State private var showBreak = false;
    @State private var showAlert = false
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        nf.zeroSymbol = ""
        return nf
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Spacer()
            
            HStack(spacing: 10) {
                Spacer()
                WatchUnit(timeUnit: .hour, time: stopWatch.hours, color: Color(red: 244/255, green: 132/255, blue: 177/255))
                Text(":").offset(y: -15).font(.largeTitle)
                WatchUnit(timeUnit: .min, time: stopWatch.minutes, color: Color(red: 96/255, green: 174/255, blue: 201/255))
                Text(":").offset(y: -15).font(.largeTitle)
                WatchUnit(timeUnit: .sec, time: stopWatch.seconds, color: Color(red: 137/255, green: 192/255, blue: 180/255))
                Spacer()
            }
            
            Spacer()
            
            HStack(spacing: 20) {
                Spacer()
                
                if showStart {
                    Button(action: {
                        stopWatch.start()
                    }) {
                        Image(systemName: "play.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 50))
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .foregroundColor(.accentColor)
                            )
                    }
                    .transition(.opacity)
                } else {
                    Button(action: {
                        let timeLog = self.stopWatch.stop()
                        timeLogs.append(timeLog)
                    }, label: {
                        Image(systemName: "stop.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 50))
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .foregroundColor(.accentColor)
                            )
                    })
                    .transition(.scale)
                    
                    Button(action: {
                        stopWatch.pause()
                    }) {
                        Image(systemName: "pause.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 50))
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .foregroundColor(.accentColor)
                            )
                    }
                    
                    Button(action: {
                        stopWatch.luchBreak()
                    }) {
                        Image(systemName: "fork.knife.circle.fill")
                            .foregroundColor(.accentColor)
                            .font(.system(size: 50))
                            .overlay(
                                Circle()
                                    .stroke(lineWidth: 4)
                                    .foregroundColor(.accentColor)
                            )
                    }
                    .transition(.scale)
                }
                
                Spacer()
            }
            .padding(5)
            
            Spacer()
            
            HStack {
                if showPause {
                    HStack {
                        Spacer()
                        Label("\(stopWatch.warmUpTimeElapsedFormatted)", systemImage: "pause.circle.fill")
                            .foregroundColor(Color.accentColor.opacity(0.7))
                        Spacer()
                    }.transition(.scale)
                }
                
                if showBreak {
                    HStack {
                        Spacer()
                        Label("\(stopWatch.lunchBreakSecondsElapsedFormatted)", systemImage: "fork.knife.circle.fill")
                            .foregroundColor(Color.accentColor.opacity(0.7))
                        Spacer()
                    }.transition(.scale)
                }
            }
            
            Spacer()
        }
        .onReceive(stopWatch.$mode) { mode in
            withAnimation(.linear(duration: 0.1)) {
                if mode == .timing {
                    showStart = false
                } else {
                    showStart = true
                }
            }
        }
        .onReceive(stopWatch.$warmUpTimeElapsedFormatted) { pause in
            withAnimation(.easeInOut(duration: 1)) {
                if pause == "00:00:00" {
                    showPause = false
                } else {
                    showPause = true
                }
            }
        }
        .onReceive(stopWatch.$lunchBreakSecondsElapsedFormatted) { lunchBreak in
            withAnimation(.easeInOut(duration: 1)) {
                if lunchBreak == "00:00:00" {
                    showBreak = false
                } else {
                    showBreak = true
                }
            }
        }
    }
}

struct WatchUnit: View {

    var timeUnit: TimeUnit
    var time: String
    var color: Color

    var body: some View {
        VStack {
            ZStack {
                let progress = getProgress()
                RoundedRectangle(cornerRadius: 15.0)
                    .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .fill(color.opacity(0.5))
                    .frame(width: 80, height: 80, alignment: .center)
                RoundedRectangle(cornerRadius: 15.0)
                    .trim(from: 0, to: progress)
                    .stroke(style: StrokeStyle(lineWidth: 7, lineCap: .round))
                    .fill(color)
                    .frame(width: 80, height: 80, alignment: .center)
                    .rotationEffect(.degrees(-90))
                    .animation(.linear, value: progress)

                HStack(spacing: 2) {
                    Text(time)
                        .font(.largeTitle)
                }
            }

            Text(timeUnit.rawValue)
                .font(.system(size: 16))
        }
    }
    
    func getProgress() -> Double {
        Double((Double(time) ?? 0.0) / (WatchUnit.TimeUnit.hour == self.timeUnit ? 24.0 : 60.0))
    }
    
    enum TimeUnit: String {
        case sec = "SEC"
        case min = "MIN"
        case hour = "HOUR"
    }
}

struct ClockView: View {
    @ObservedObject var stopWatch: StopWatch
    
    var body: some View {
        VStack {
            Text("Elapsed time").textCase(.uppercase)
            Text("\(stopWatch.warmUpTimeElapsedFormatted)")
                .font(.largeTitle)
        }
    }
}

struct WorkClockView_Previews: PreviewProvider {
    
    struct StatefulPreviewWrapper: View {
        @State private var timeLogs: [TimeLog] = []
        
        var body: some View {
            WorkClockView(timeLogs: $timeLogs)
        }
    }
    
    static var previews: some View {
        StatefulPreviewWrapper()
    }
}
