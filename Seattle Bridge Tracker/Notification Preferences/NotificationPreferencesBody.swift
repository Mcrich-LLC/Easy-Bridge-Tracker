//
//  NotificationPreferencesBody.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/27/23.
//

import SwiftUI
import Mcrich23_Toolkit
import SwiftUIX

struct NotificationPreferencesBody: View {
    @Binding var preference: NotificationPreferences
    @ObservedObject var preferencesModel = NotificationPreferencesModel.shared
    @ObservedObject var contentViewModel = ContentViewModel.shared
    @State var isEditingTitle = false
    @State var titleEditorIsFocused = false
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
                                    TitleTextEditor(text: $editedTitle, isEditing: $titleEditorIsFocused, clearButtonMode: .whileEditing) {
                                        preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle, showTextEditorIfDuplicate: false) {
                                            isEditingTitle = false
                                        }
                                    }
                                    .minimumScaleFactor(0.6)
                                    .padding(.leading)
                                    .accessibility(identifier: "Title Editor")
                                }
                                .padding([.top, .trailing, .bottom], 5.0)
                            }
                            .background(Color.gray.opacity(0.3))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .frame(maxWidth: 150)
                            Button {
                                editedTitle = preference.title
                                withAnimation {
                                    self.titleEditorIsFocused = false
                                    self.isEditingTitle = false
                                }
                            } label: {
                                Text("X")
                                    .foregroundColor(.red)
                            }
                            .hoverEffect(.highlight)
                            Button {
                                preferencesModel.saveUpdatedTitle(for: preference, with: editedTitle, showTextEditorIfDuplicate: false) {
                                    withAnimation {
                                        self.titleEditorIsFocused = false
                                        self.isEditingTitle = false
                                    }
                                }
                            } label: {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.green)
                            }
                            .hoverEffect(.highlight)
                        } else {
                            Text(preference.title)
                                .font(.title2)
                            Button {
                                withAnimation {
                                    self.isEditingTitle = true
                                    self.titleEditorIsFocused = true
                                }
                            } label: {
                                Image(systemName: "square.and.pencil")
                            }
                            .hoverEffect(.highlight)
                        }
                    }
                    Spacer()
                    Button {
                        preferencesModel.duplicateNotificationPreferenceAlert(basedOn: preference, onDone: {})
                    } label: {
                        Image(systemName: "doc.on.doc")
                    }
                    .hoverEffect(.highlight)
                    Button {
                        preferencesModel.deleteNotificationPreference(preference: preference)
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .foregroundColor(Color.red)
                    }
                    .hoverEffect(.highlight)
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
