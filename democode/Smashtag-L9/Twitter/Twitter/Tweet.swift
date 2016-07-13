//
//  Tweet.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// a simple container class which just holds the data in a Tweet
// a Mention is a substring of the Tweet's text
// for example, a hashtag or other user or url that is mentioned in the Tweet
// note carefully the comments on the range property in a Mention
// Tweet instances are created by fetching from Twitter using a Twitter.Request

public class Tweet : NSObject
{
    public let text: String
    public let user: User
    public let created: NSDate
    public let id: String
    public let media: [MediaItem]
    public let hashtags: [Mention]
    public let urls: [Mention]
    public let userMentions: [Mention]
    
    public override var description: String { return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + "\nid: \(id)" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?)
    {
        guard
            let user = User(data: data?.valueForKeyPath(TwitterKey.User) as? NSDictionary),
            let text = data?.valueForKeyPath(TwitterKey.Text) as? String,
            let created = (data?.valueForKeyPath(TwitterKey.Created) as? String)?.asTwitterDate,
            let id = data?.valueForKeyPath(TwitterKey.ID) as? String
        else {
            return nil
        }

        self.user = user
        self.text = text
        self.created = created
        self.id = id

        self.media = Tweet.mediaItemsFromTwitterData(data?.valueForKeyPath(TwitterKey.Media) as? NSArray)
        self.hashtags = Tweet.mentionsFromTwitterData(data?.arrayForKeyPath(TwitterKey.Entities.Hashtags), inText: text, withPrefix: "#")
        self.urls = Tweet.mentionsFromTwitterData(data?.arrayForKeyPath(TwitterKey.Entities.URLs), inText: text, withPrefix: "http")
        self.userMentions = Tweet.mentionsFromTwitterData(data?.arrayForKeyPath(TwitterKey.Entities.UserMentions), inText: text, withPrefix: "@")
    }
    
    private static func mediaItemsFromTwitterData(twitterData: NSArray?) -> [MediaItem] {
        var mediaItems = [MediaItem]()
        for mediaItemData in twitterData ?? [] {
            if let mediaItem = MediaItem(data: mediaItemData as? NSDictionary) {
                mediaItems.append(mediaItem)
            }
        }
        return mediaItems
    }
    
    private static func mentionsFromTwitterData(twitterData: NSArray?, inText text: String, withPrefix prefix: String) -> [Mention] {
        var mentions = [Mention]()
        for mentionData in twitterData ?? [] {
            if let mention = Mention(fromTwitterData: mentionData as? NSDictionary, inText: text, withPrefix: prefix) {
                mentions.append(mention)
            }
        }
        return mentions
    }
    
    struct TwitterKey {
        static let User = "user"
        static let Text = "text"
        static let Created = "created_at"
        static let ID = "id_str"
        static let Media = "entities.media"
        struct Entities {
            static let Hashtags = "entities.hashtags"
            static let URLs = "entities.urls"
            static let UserMentions = "entities.user_mentions"
            static let Indices = "indices"
            static let Text = "text"
        }
    }
}

public class Mention: NSObject
{
    public let keyword: String              // will include # or @ or http prefix
    public let nsrange: NSRange             // index into an NS[Attributed]String made from the Tweet's text
    
    public override var description: String { return "\(keyword) (\(nsrange.location), \(nsrange.location+nsrange.length-1))" }
    
    init?(fromTwitterData data: NSDictionary?, inText text: NSString, withPrefix prefix: String)
    {
        guard
            let indices = data?.valueForKeyPath(Tweet.TwitterKey.Entities.Indices) as? NSArray,
            let start = (indices.firstObject as? NSNumber)?.integerValue where start >= 0,
            let end = (indices.lastObject as? NSNumber)?.integerValue where end > start
            else {
                return nil
        }
        
        var prefixAloneOrPrefixedMention = prefix
        if let mention = data?.valueForKeyPath(Tweet.TwitterKey.Entities.Text) as? String {
            prefixAloneOrPrefixedMention = mention.prependPrefixIfAbsent(prefix)
        }
        let expectedRange = NSRange(location: start, length: end - start)
        guard
            let nsrange = text.rangeOfSubstringWithPrefix(prefixAloneOrPrefixedMention, expectedRange: expectedRange)
            else {
                return nil
        }
        
        self.keyword = text.substringWithRange(nsrange)
        self.nsrange = nsrange
    }
}

private let twitterDateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
    formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return formatter
}()

private extension String {
    var asTwitterDate: NSDate? {
        return twitterDateFormatter.dateFromString(self)
    }
}

private extension NSDictionary {
    func arrayForKeyPath(keypath: String) -> NSArray? {
        return self.valueForKeyPath(keypath) as? NSArray
    }
}

private extension String {
    func prependPrefixIfAbsent(prefix: String) -> String {
        if hasPrefix(prefix) {
            return self
        } else {
            return prefix + self
        }
    }
}

private extension NSString
{
    func rangeOfSubstringWithPrefix(prefix: String, expectedRange: NSRange) -> NSRange?
    {
        var offset = 0
        var substringRange = expectedRange
        while range.contains(substringRange) && substringRange.intersects(expectedRange) {
            if substringWithRange(substringRange).hasPrefix(prefix) {
                return substringRange
            }
            offset = offset > 0 ? -(offset+1) : -(offset-1)
            substringRange.location += offset
        }
        
        // the prefix does not intersect the expectedRange
        // let's search for it elsewhere and if we find it,
        // pick the one closest to expectedRange
        
        var searchRange = range
        var bestMatchRange = NSRange.NotFound
        var bestMatchDistance = Int.max
        repeat {
            substringRange = rangeOfString(prefix, options: [], range: searchRange)
            let distance = substringRange.distanceFrom(expectedRange)
            if distance < bestMatchDistance {
                bestMatchRange = substringRange
                bestMatchDistance = distance
            }
            searchRange.length -= substringRange.end - searchRange.start
            searchRange.start = substringRange.end
        } while searchRange.length > 0
        
        if bestMatchRange.location != NSNotFound {
            bestMatchRange.length = expectedRange.length
            if range.contains(bestMatchRange) {
                return bestMatchRange
            }
        }
        
        print("NSString.rangeOfKeywordWithPrefix(expectedRange:) couldn't find a keyword with the prefix \(prefix) near the range \(expectedRange) in \(self)")

        return nil
    }
    
    var range: NSRange { return NSRange(location:0, length: length) }
}

private extension NSRange
{
    func contains(range: NSRange) -> Bool {
        return range.location >= location && range.location+range.length <= location+length
    }

    func intersects(range: NSRange) -> Bool {
        if range.location == NSNotFound || location == NSNotFound {
            return false
        } else {
            return (range.start >= start && range.start < end) || (range.end >= start && range.end < end)
        }
    }
    
    func distanceFrom(range: NSRange) -> Int {
        if range.location == NSNotFound || location == NSNotFound {
            return Int.max
        } else if intersects(range) {
            return 0
        } else {
            return (end < range.start) ? range.start - end : start - range.end
        }
    }
    
    static let NotFound = NSRange(location: NSNotFound, length: 0)
    
    var start: Int {
        get { return location }
        set { location = newValue }
    }

    var end: Int { return location+length }
}
