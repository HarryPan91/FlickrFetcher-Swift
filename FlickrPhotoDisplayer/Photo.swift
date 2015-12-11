//
//  Photo.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 10/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

struct Photo {
    var unique: String
    var title: String
    var subtitle: String
    var imageURL: NSURL
    var thumbnailURL: NSURL
    var owner: String

    init?(photo: [String: AnyObject]) {
        guard let unique = photo[FlickrFetcher.Constants.FLICKR_PHOTO_ID] as? String,
            title = photo[FlickrFetcher.Constants.FLICKR_PHOTO_TITLE] as? String,
            imageURL = FlickrFetcher.URLforPhoto(photo, format: .Large),
            thumbnailURL = FlickrFetcher.URLforPhoto(photo, format: .Square),
            photographer = photo[FlickrFetcher.Constants.FLICKR_PHOTO_OWNER] as? String else {
                return nil
        }

        self.subtitle = (photo[FlickrFetcher.Constants.FLICKR_PHOTO_DESCRIPTION] ?? "NO SUBTITLE") as! String

        self.unique = unique
        if title == "" {
            self.title = "NO TITLE"
        } else {
            self.title = title
        }
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.owner = photographer
    }
}