//
//  NotificationPreferencesBody.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit

struct NotificationPreferencesBody: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemGroupedBackground)
            VStack {
                HStack {
                    Text(preference.title)
                        .font(.title2)
                    Button {
                        preferencesModel.updateTitle(for: preference)
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .imageScale(.large)
                    }
                    Spacer()
                    Button {
                        preferencesModel.duplicateNotificationPreference(basedOn: preference, onDone: {})
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    Button {
                        preferencesModel.deleteNotificationPreference(preference: preference)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                        .foregroundColor(Color.red)
                    }
                }
                Divider()
                    .padding(.bottom)
                NotificationPreferenceDaysPicker(preference: $preference)
                NotificationPreferencesTimePicker(preference: $preference)
                NotificationPreferencesImportance(preference: $preference)
                NotificationPreferencesSelectedBridges(preference: $preference)
                NotificationPreferencesActiveToggle(preference: $preference)
            }
            .padding()
        }
    }
}

struct NotificationPreferencesBody_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesBody(preference: .constant(.defaultPreferences))
    }
}
