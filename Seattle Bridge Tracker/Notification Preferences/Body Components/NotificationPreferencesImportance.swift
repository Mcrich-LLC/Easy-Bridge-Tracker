//
//  NotificationPreferencesImportance.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI

struct NotificationPreferencesImportance: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        HStack {
            if #available(iOS 15, *) {
                Text("Importance: ")
            }
            Spacer()
            Picker(selection: Binding(get: {
                preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.notificationPriority
            }, set: { newValue in
                    self.preference.notificationPriority = newValue
            })) {
                ForEach(NotificationPriority.allCases, id: \.self) { notificationPriority in
                    Text(notificationPriority.rawValue.capitalized)
                }
            } label: {
                Text("Importance: ")
            }
        }
    }
}

struct NotificationPreferencesImportance_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesImportance(preference: .constant(.defaultPreferences))
    }
}
