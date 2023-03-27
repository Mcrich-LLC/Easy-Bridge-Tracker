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
                    NotificationPreferencesBody(preference: preference)
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
