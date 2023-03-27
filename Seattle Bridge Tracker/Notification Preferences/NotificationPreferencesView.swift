//
//  NotificationPreferences.swift
//  NotificationService
//
//  Created by Morris Richman on 3/26/23.
//

import SwiftUI
import Mcrich23_Toolkit
import SwiftUIBackports
import ScrollViewIfNeeded

struct NotificationPreferencesView: View {
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel: ContentViewModel
    @Environment(\.backportDismiss) var dismiss
    var body: some View {
        ScrollViewIfNeeded {
            HStack {
                Text("Notification Schedule")
                    .font(.title)
                Spacer()
                Button {
                    preferencesModel.preferencesArray.append(.defaultPreferences)
                } label: {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }
                Button {
                    dismiss.callAsFunction()
                } label: {
                    Image(systemName: "x.circle")
                        .imageScale(.large)
                }
            }
            LazyVStack(spacing: 10) {
                ForEach(preferencesModel.preferencesArray, id: \.self) { preference in
                    NotificationPreferencesBody(preference: Binding(get: {
                        guard let prefs = preferencesModel.preferencesArray.first(where: { $0.id == preference.id }) else {
                            return .defaultPreferences
                        }
                        return prefs
                    }, set: { newValue in
                        if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                            preferencesModel.preferencesArray[index] = newValue
                        }
                    }))
                }
            }
        }
        .padding()
        .onAppear {
            preferencesModel.getPreferences()
        }
    }
}

struct NotificationPreferences_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesView(contentViewModel: ContentViewModel())
    }
}
