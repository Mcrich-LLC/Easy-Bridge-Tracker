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
import WrappingHStack

struct NotificationPreferencesView: View {
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @Environment(\.backportDismiss) var dismiss
    var body: some View {
        ScrollViewIfNeeded {
            VStack {
                HStack {
                    Text("Notification Schedule")
                        .font(.title)
                    Spacer()
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                preferencesModel.createNotificationPreference(onDone: {})
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
                        .padding(.bottom, 1)
                        Button {
                            if !preferencesModel.preferencesArray.compactMap({ $0.isActive }).contains(true) {
                                for prefIndex in preferencesModel.preferencesArray.indices {
                                    preferencesModel.preferencesArray[prefIndex].isActive = true
                                }
                            } else {
                                for prefIndex in preferencesModel.preferencesArray.indices {
                                    preferencesModel.preferencesArray[prefIndex].isActive = false
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                if !preferencesModel.preferencesArray.compactMap({ $0.isActive }).contains(true) {
                                    HStack {
                                        Text("Resume All")
                                        Image(systemName: "arrowtriangle.forward.circle")
                                    }
                                } else {
                                    HStack {
                                        Text("Pause All")
                                        Image(systemName: "pause.circle")
                                    }
                                }
                            }
                        }
                    }
                }
                if !preferencesModel.notificationsAllowed {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.yellow)
                        WrappingHStack {
                            Text("Warning: Notifications Are Disabled")
                                .foregroundColor(.white)
                            Button("Fix It") {
                                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(appSettings)
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(height: 70)
                }
                if preferencesModel.preferencesArray.isEmpty {
                    VStack {
                        Spacer()
                        Text("You don't have any notification schedules.")
                        Button {
                            preferencesModel.createNotificationPreference {}
                        } label: {
                            Text("Get Started")
                        }
                        Spacer()
                    }
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(preferencesModel.preferencesArray, id: \.self) { preference in
                            if preferencesModel.preferencesArray.first?.id == preference.id {
                                NotificationPreferencesAd()
                            }
                            if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }), index.isMultiple(of: 3), preferencesModel.preferencesArray.first?.id != preference.id {
                                NotificationPreferencesAd()
                            }
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
            }
            .padding()
        }
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
