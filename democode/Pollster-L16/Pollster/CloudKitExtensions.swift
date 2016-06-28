//
//  CloudKitExtensions.swift
//  Pollster
//
//  Created by CS193p Instructor.
//  Copyright © 2016 Stanford University. All rights reserved.
//

import CloudKit

// these are read-only
// one could make read-write versions of them just as easily

extension CKRecord {
    var question: String {
        return self[Cloud.Attribute.Question] as? String ?? ""
    }
    var answers: [String] {
        return self[Cloud.Attribute.Answers] as? [String] ?? []
    }
}

// Constants

struct CloudKitNotifications {
    static let NotificationReceived = "iCloudRemoteNotificationReceived"
    static let NotificationKey = "Notification"
}

struct Cloud {
    struct Entity {
        static let QandA = "QandA"
        static let Response = "Response"
    }
    struct Attribute {
        static let Question = "question"
        static let Answers = "answers"
        static let ChosenAnswer = "chosenAnswer"
        static let QandA = "qanda"
    }
}

// probably in a real application
// you'd have an Entity in the database for users
// and so you wouldn't use this way of determining whether
// the record was authored by the currently-logged-in iCloud user

extension CKRecord {
    var wasCreatedByThisUser: Bool {
        // is this really the right way to do this?
        // seems like this Bool property should be built in to CKRecord
        return (creatorUserRecordID == nil) || (creatorUserRecordID?.recordName == "__defaultOwner__")
    }
}

