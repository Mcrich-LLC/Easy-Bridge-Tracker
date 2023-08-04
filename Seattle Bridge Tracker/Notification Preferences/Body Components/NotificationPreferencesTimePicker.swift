//
//  NotificationPreferencesTimePicker.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit

struct NotificationPreferencesTimePicker: View {
    @Binding var preference: NotificationPreferences
    @State var startTime = Date()
    @State var endTime = Date()
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    
    init(preference: Binding<NotificationPreferences>) {
        self._preference = preference
        self._startTime = State(initialValue: formattedDate(preferencesModel.preferencesArray.first(where: { $0.id == preference.wrappedValue.id })?.startTime))
        self._endTime = State(initialValue: formattedDate(preferencesModel.preferencesArray.first(where: { $0.id == preference.wrappedValue.id })?.endTime))
    }
    
    func formattedDate(_ date: String?) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.date(from: date ?? "8:00 AM")!
    }
    
    func formattedString(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: date)
    }
    
    var body: some View {
        Toggle("All Day", isOn: $preference.isAllDay)
        if !preference.isAllDay {
            VStack {
                DatePicker("Start Time: ", selection: $startTime, displayedComponents: [.hourAndMinute])
                DatePicker("End Time: ", selection: $endTime, displayedComponents: [.hourAndMinute])
            }
            .onChange(of: startTime) { newValue in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(2)) {
                    self.preference.startTime = formattedString(newValue)
                }
            }
            .onChange(of: endTime) { newValue in
                DispatchQueue.main.asyncAfter(wallDeadline: .now() + .seconds(2)) {
                    self.preference.endTime = formattedString(newValue)
                }
            }
        }
        if endTime < startTime {
            Text("This notification schedule will not run")
                .foregroundColor(.systemYellow)
                .multilineTextAlignment(.center)
        }
    }
}
