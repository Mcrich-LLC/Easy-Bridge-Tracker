//
//  NotificationPreferencesDecoder.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 3/26/23.
//

import Foundation

struct NotificationPreferences: Hashable, Codable, Identifiable, Equatable {
    var id = UUID()
    var title: String
    var days: [Day]?
    var startTime: String
    var endTime: String
    var notificationPriority: NotificationPriority?
    var bridgeIds: [UUID]
    
    init(id: UUID = UUID(), title: String, days: [Day]? = nil, startTime: String, endTime: String, notificationPriority: NotificationPriority? = nil, bridgeIds: [String]) {
        self.id = id
        self.title = title
        self.days = days
        self.startTime = startTime
        self.endTime = endTime
        self.notificationPriority = notificationPriority
        self.bridgeIds = bridgeIds.map({ UUID(uuidString: $0)! })
    }
    
    init(id: UUID = UUID(), title: String, days: [String], startTime: String, endTime: String, notificationPriority: String, bridgeIds: [String]) {
        self.id = id
        self.title = title
        self.days = days.map { Day(rawValue: $0)! }
        self.startTime = startTime
        self.endTime = endTime
        self.notificationPriority = NotificationPriority(rawValue: notificationPriority)
        self.bridgeIds = bridgeIds.map({ UUID(uuidString: $0)! })
    }
    
    static let defaultPreferences = Self(id: UUID(), title: "Untitled", days: [], startTime: "8:00 AM", endTime: "5:00 PM", notificationPriority: .normal, bridgeIds: [])
}

enum NotificationPriority: String, CaseIterable, Codable, Hashable {
    case timeSensitive = "time sensitive"
    case normal = "normal"
    case silent = "silent"
}

enum Day: String, CaseIterable, Codable, Hashable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func currentDay() -> Self? {
        guard let day = Date().dayOfWeek() else {
            return nil
        }
        return Self(rawValue: day)
    }
    
    static func stringsCapitalized(for days: [Self]) -> [String] {
        days.map { $0.rawValue.capitalized }
    }
}

extension Date {
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: self).lowercased()
    }
}

extension Formatter {
    static let today: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = .init(identifier: "en_US_POSIX")
        dateFormatter.defaultDate = Calendar.current.startOfDay(for: Date())
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter
    }()
}
