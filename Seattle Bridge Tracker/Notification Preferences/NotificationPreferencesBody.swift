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
                        var title = "this"
                        if let pref = preferencesModel.preferencesArray.first(where: { $0.id == preference.id }) {
                            title = "your \(pref.title)"
                        }
                        SwiftUIAlert.show(title: "Confirm Deletion", message: "Are you sure that you want to delete \(title) schedule?", preferredStyle: .alert, actions: [.init(title: "Cancel", style: .destructive), .init(title: "Yes", style: .default, handler: { _ in
                            if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                self.preferencesModel.preferencesArray.remove(at: index)
                            }
                        })])
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
