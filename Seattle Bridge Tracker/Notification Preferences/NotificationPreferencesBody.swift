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
    @State var isEditingTitle = false
    @State var editedTitle = ""
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.systemGroupedBackground)
            VStack {
                HStack {
                    HStack {
                        if isEditingTitle {
                            HStack {
                                Group {
                                    TextField(text: $editedTitle, onCommit: {
                                        preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle) {
                                            isEditingTitle = false
                                        }
                                    })
                                    .minimumScaleFactor(0.6)
                                    .padding(.leading)
                                    .accessibility(identifier: "Title Editor")
                                    if !editedTitle.isEmpty {
                                        Button(action: {
                                            editedTitle = ""
                                        }, label: {
                                            Image(systemName: "xmark.circle")
                                                .foregroundColor(Color.gray)
                                        })
                                        .hoverEffect(.highlight)
                                    }
                                }
                                .padding([.top, .trailing, .bottom], 5.0)
                            }
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        } else {
                            Text(preference.title)
                                .font(.title2)
                        }
                    }
                    
                    if isEditingTitle {
                        HStack {
                            Button {
                                editedTitle = preference.title
                                withAnimation {
                                    self.isEditingTitle = false
                                }
                            } label: {
                                Text("X")
                                    .foregroundColor(.red)
                            }
                            Button {
                                preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle) {
                                    withAnimation {
                                        self.isEditingTitle = false
                                    }
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                        }
                    } else {
                        Button {
                            withAnimation {
                                self.isEditingTitle = true
                            }
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                    Spacer()
                    Button {
                        preferencesModel.duplicateNotificationPreferenceAlert(basedOn: preference, onDone: {})
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
                .imageScale(.large)
                .frame(height: 40)
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
        .onAppear {
            self.editedTitle = preference.title
        }
    }
}

struct NotificationPreferencesBody_Previews: PreviewProvider {
    static var previews: some View {
        NotificationPreferencesBody(preference: .constant(.defaultPreferences))
    }
}
