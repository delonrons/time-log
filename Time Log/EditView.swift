//
//  EditView.swift
//  Time Log
//
//  Created by Delon Rons on 28/11/2022.
//

import SwiftUI

struct EditView: View {
    
    var isEdit: Bool = false
    @Binding var timeLog: TimeLog
    @State var packets: Int32?
    @State private var numberFormatter: NumberFormatter = {
        var nf = NumberFormatter()
        nf.numberStyle = .none
        nf.zeroSymbol = ""
        return nf
    }()
    
    var body: some View {
        
        Form {
            Section {
                DatePicker("Date", selection: self.$timeLog.date, displayedComponents: .date)
                    .disabled(isEdit)
                
                HStack {
                    Text("Total")
                    Spacer()
                    TimeEditPicker(time: $timeLog.total)
                }
                HStack {
                    Text("Pause")
                    Spacer()
                    TimeEditPicker(time: $timeLog.pause)
                }
                HStack {
                    Text("Break")
                    Spacer()
                    TimeEditPicker(time: $timeLog.lunchBreak)
                }
                
                HStack {
                    Text("Packets").padding([.trailing], 35)
                    Spacer()
                    TextField("1000", value: $timeLog.numberOfPackets, formatter: numberFormatter)
                        .textContentType(.dateTime)
                        .keyboardType(.numberPad)
                }
            }.padding(15)
        }
    }
}

struct TimeEditPicker: View {
    @Binding var time: Time

    var body: some View {
                HStack {
                    Picker("", selection: $time.hour){
                        ForEach(0..<24, id: \.self) { i in
                            Text("\(i) hours").tag(Int32(i))
                        }
                    }
                    Picker("", selection: $time.minute){
                        ForEach(0..<60, id: \.self) { i in
                            Text("\(i) min").tag(Int32(i))
                        }
                    }
                }
                
    }
}


struct EditView_Previews: PreviewProvider {
     @State static var timeLog = TimeLog(
        date: Date(),
        total: Time(hour: 10, minute: 20, second: 30),
        lunchBreak: Time(hour: 0, minute: 10, second: 30),
        pause: Time(hour: 0, minute: 30, second: 00),
        numberOfPackets: 1000
    );
    
    static var previews: some View {
        EditView(
            timeLog: $timeLog
        )
    }
}
