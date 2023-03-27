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
    @EnvironmentObject var preferencesModel: NotificationPreferencesModel
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.systemGroupedBackground)
                        VStack {
                            HStack {
                                Text(preference.title)
                                    .font(.title2)
                                Button {
                                    preferencesModel.setTitle(for: preference)
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
                                            preferencesModel.preferencesArray.remove(at: index)
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
                                            if !((preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.days ?? []).contains(day)) {
                                                Button {
                                                    if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                                        preferencesModel.preferencesArray[index].days?.append(day)
                                                    }
                                                } label: {
                                                    Text(day.rawValue.capitalized)
                                                }
                                            }
                                        }
                                    }
                                }), opt: .constant(Day.stringsCapitalized(for: Day.allCases)), selected: Binding(get: {
                                    let days = preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.days ?? []
                                    return Day.stringsCapitalized(for: days)
                                }, set: { newValue in
                                    let lowercasedDays = newValue.map { $0.lowercased() }
                                    let days = lowercasedDays.map({ Day(rawValue: $0)! })
                                    if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                        preferencesModel.preferencesArray[index].days = days
                                    }
                                }))
                                Spacer()
                            }
                            .padding(.bottom)
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
                                if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                    preferencesModel.preferencesArray[index].startTime =
                                    dateFormatter.string(from: newValue)
                                }
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
                                if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                    preferencesModel.preferencesArray[index].endTime = dateFormatter.string(from: newValue)
                                }
                            }), displayedComponents: [.hourAndMinute])
                            HStack {
                                if #available(iOS 15, *) {
                                    Text("Importance: ")
                                }
                                Spacer()
                                Picker(selection: Binding(get: {
                                    preferencesModel.preferencesArray.first(where: { $0.id == preference.id })?.notificationPriority
                                }, set: { newValue in
                                    if let index = preferencesModel.preferencesArray.firstIndex(where: { $0.id == preference.id }) {
                                        preferencesModel.preferencesArray[index].notificationPriority = newValue
                                    }
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
                                                    if preferencesModel.preferencesArray[index].bridgeIds.contains(bridge.id) {
                                                        preferencesModel.preferencesArray[index].bridgeIds.remove(at: index)
                                                        preferencesModel.removeSubscription(for: bridge)
                                                    } else if !preferencesModel.preferencesArray[index].bridgeIds.contains(bridge.id) {
                                                        preferencesModel.preferencesArray[index].bridgeIds.append(bridge.id)
                                                        preferencesModel.addSubscription(for: bridge)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Select Bridges")
                                }
                            }
                        }
                        .padding()
                    }
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
