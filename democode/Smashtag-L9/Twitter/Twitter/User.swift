//
//  User.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// container to hold data about a Twitter user

public class User: NSObject
{
    public let screenName: String
    public let name: String
    public let id: String
    public let verified: Bool
    public let profileImageURL: NSURL?
    
    public override var description: String { return "@\(screenName) (\(name))\(verified ? " ✅" : "")" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?) {
        guard
            let screenName = data?.valueForKeyPath(TwitterKey.ScreenName) as? String,
            let name = data?.valueForKeyPath(TwitterKey.Name) as? String,
            let id = data?.valueForKeyPath(TwitterKey.ID) as? String
        else {
            return nil
        }
        
        self.screenName = screenName
        self.name = name
        self.id = id

        self.verified = data?.valueForKeyPath(TwitterKey.Verified)?.boolValue ?? false
        let urlString = data?.valueForKeyPath(TwitterKey.ProfileImageURL) as? String ?? ""
        self.profileImageURL = (urlString.characters.count > 0) ? NSURL(string: urlString) : nil
    }
    
    var asPropertyList: AnyObject {
        return [
            TwitterKey.Name:name,
            TwitterKey.ScreenName:screenName,
            TwitterKey.ID:id,
            TwitterKey.Verified:verified ? "YES" : "NO",
            TwitterKey.ProfileImageURL:profileImageURL?.absoluteString ?? ""
        ]
    }
    
    struct TwitterKey {
        static let Name = "name"
        static let ScreenName = "screen_name"
        static let ID = "id_str"
        static let Verified = "verified"
        static let ProfileImageURL = "profile_image_url"
    }
}
