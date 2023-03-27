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
                NotificationPreferencesTimePicker(preference: $preference)
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
                HStack {
                    Text("Bridges: ")
                    Spacer()
                    Button {
                        Mcrich23_Toolkit.topVC().present {
                            if let prefs = preferencesModel.preferencesArray.first(where: { $0.id == preference.id }) {
                                NotificationContentView(viewModel: contentViewModel, bridgeIds: prefs.bridgeIds) { bridge in
                                    if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                        if self.preference.bridgeIds.contains(bridge.id) {
                                            self.preference.bridgeIds.remove(at: index)
                                            preferencesModel.removeSubscription(for: bridge)
                                        } else if !self.preference.bridgeIds.contains(bridge.id) {
                                            self.preference.bridgeIds.append(bridge.id)
                                            preferencesModel.addSubscription(for: bridge)
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        if preference.bridgeIds.isEmpty {
                            Text("Select Bridge")
                        } else if let bridgeId = preference.bridgeIds.first, let bridge = contentViewModel.allBridges.first(where: { $0.id == bridgeId }), preference.bridgeIds.count == 1 {
                            Text("\(bridge.name), \(bridge.bridgeLocation)")
                        } else {
                            Text("\(preference.bridgeIds.count) Bridges Selected")
                        }
                    }
                }
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
