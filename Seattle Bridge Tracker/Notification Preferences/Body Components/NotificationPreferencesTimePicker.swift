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
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        Toggle("All Day", isOn: Binding(get: {
            preference.isAllDay
        }, set: { isAllDay in
            self.preference.isAllDay = isAllDay
        }))
        if !preference.isAllDay {
            VStack {
                DatePicker("Start Time: ", selection: Binding(get: {
                    let startTime = preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.startTime
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .init(identifier: "en_US_POSIX")
                    dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
                    dateFormatter.dateFormat = "hh:mm a"
                    return dateFormatter.date(from: startTime ?? "8:00 AM")!
                }, set: { newValue in
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .init(identifier: "en_US_POSIX")
                    dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
                    dateFormatter.dateFormat = "hh:mm a"
                    self.preference.startTime = dateFormatter.string(from: newValue)
                }), displayedComponents: [.hourAndMinute])
                DatePicker("End Time: ", selection: Binding(get: {
                    let endTime = preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.endTime
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .init(identifier: "en_US_POSIX")
                    dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
                    dateFormatter.dateFormat = "hh:mm a"
                    return dateFormatter.date(from: endTime ?? "8:00 AM")!
                }, set: { newValue in
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = .init(identifier: "en_US_POSIX")
                    dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
                    dateFormatter.dateFormat = "hh:mm a"
                    self.preference.endTime = dateFormatter.string(from: newValue)
                }), displayedComponents: [.hourAndMinute])
            }
        }
    }
}
