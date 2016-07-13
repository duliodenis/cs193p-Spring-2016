//
//  MediaItem.swift
//  Twitter
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

// holds the network url and aspectRatio of an image attached to a Tweet
// created automatically when a Tweet object is created

public class MediaItem: NSObject
{
    public let url: NSURL
    public let aspectRatio: Double
    
    public override var description: String { return "\(url.absoluteString) (aspect ratio = \(aspectRatio))" }
    
    // MARK: - Internal Implementation
    
    init?(data: NSDictionary?) {
        guard
            let height = data?.valueForKeyPath(TwitterKey.Height) as? Double where height > 0,
            let width = data?.valueForKeyPath(TwitterKey.Width) as? Double where width > 0,
            let urlString = data?.valueForKeyPath(TwitterKey.MediaURL) as? String,
            let url = NSURL(string: urlString)
        else {
            return nil
        }
        self.url = url
        self.aspectRatio = width/height
    }
    
    struct TwitterKey {
        static let MediaURL = "media_url_https"
        static let Width = "sizes.small.w"
        static let Height = "sizes.small.h"
    }
}
