//
//  NotificationPreferenceDaysPicker.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit

struct NotificationPreferenceDaysPicker: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        HStack {
            AdaptiveCapsuleMultiFilter("Days: ", menuContent: .constant({
                VStack {
                    ForEach(Day.allCases, id: \.self) { day in
                        if let days = preference.days, !days.contains(day) {
                            Button {
                                self.preference.days?.append(day)
                            } label: {
                                Text(day.rawValue.capitalized)
                            }
                        }
                    }
                }
            }), opt: .constant(Day.stringsCapitalized(for: Day.allCases)), selected: Binding(get: {
                let days = self.preference.days ?? []
                return Day.stringsCapitalized(for: days)
            }, set: { newValue in
                let lowercasedDays = newValue.map { $0.lowercased() }
                let days = lowercasedDays.map({ Day(rawValue: $0)! })
                self.preference.days = days
            }))
            Spacer()
        }
        .padding(.bottom)
    }
}

struct NotificationPreferenceDaysPicker_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferenceDaysPicker(preference: .constant(.defaultPreferences))
    }
}
