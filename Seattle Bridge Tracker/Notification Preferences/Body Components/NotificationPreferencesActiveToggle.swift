//
//  NotificationPreferencesActiveToggle.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI

struct NotificationPreferencesActiveToggle: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        Toggle("Active", isOn: Binding(get: {
            preference.isActive
        }, set: { isActive in
            self.preference.isActive = isActive
        }))
    }
}

struct NotificationPreferencesActiveToggle_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesActiveToggle(preference: .constant(.defaultPreferences))
    }
}
