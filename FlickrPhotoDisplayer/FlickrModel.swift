//
//  FlickrModel.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 3/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation
import UIKit

let FlickrInfoDownloaded = "FlickrInfoDownloadComplete"
let FlickrPhoto = "FlickrPhoto"

struct Photo {
    var unique: String
    var title: String
    var subtitle: String
    var imageURL: NSURL
    var thumbnailURL: NSURL
    var owner: String

    init(unique: String, title: String, subtitle: String?, owner: String, thumbnailURL: NSURL, imageURL: NSURL) {
        // REVIEW: Just ues `self.subtitle = subtitle ?? "NO SUBTITLE"` is enough

        self.subtitle = subtitle ?? "NO SUBTITLE"

        self.unique = unique
        if title == "" {
            self.title = "NO TITLE"
        } else {
            self.title = title
        }
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.owner = owner
    }
}

// REVIEW: What is the use of this class?
// prepare(fetch) the data for controllers
class FlickrModel {

    // REVIEW: If photographer is an array, please use plural.
    var photographers = [String: [Photo]]()
    

    init() {
        fetch()
    }

    private func fetch() {
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        sessionConfig.allowsCellularAccess = false
        let session = NSURLSession.init(configuration: sessionConfig)
        let request = NSURLRequest.init(URL: FlickrFetcher.URLforRecentGeoreferencedPhotos()!)
        let task = session.downloadTaskWithRequest(request) { (localFile, response, error) -> Void in
            if let e = error {
                print("Flickr background fetch failed: \(e.localizedDescription)")
            } else {
                if let photos = self.flickrPhotosAtURL(localFile!) {
                    self.loadImagesFromFlickrArray(photos)
                }
            }
        }
        task.resume()
    }


    private func flickrPhotosAtURL(url: NSURL) -> Array<[String: AnyObject]>? {
        let flickrJSONData = NSData.init(contentsOfURL: url)
        guard flickrJSONData != nil else {
            return nil
        }
        do {
            let jsonResult = try NSJSONSerialization.JSONObjectWithData(flickrJSONData!, options: []) as! [String: AnyObject]
            let photos = jsonResult["photos"]!
            // REVIEW: Please use `[[String: AnyObject]]` instead of `Array<[String: AnyObject]>`
            return photos["photo"] as? [[String: AnyObject]]
        } catch let e as NSError {
            print("\(e)")
        }
        return nil
    }

    private func loadImagesFromFlickrArray(photos: Array<[String: AnyObject]>) {
        for photo in photos {
            // REVIEW: Too many `if let`, please use `guard let` instead.

            guard let unique = photo[FlickrFetcher.Constants.FLICKR_PHOTO_ID] as? String,
                title = photo[FlickrFetcher.Constants.FLICKR_PHOTO_TITLE] as? String,
                imageURL = FlickrFetcher.URLforPhoto(photo, format: .Large),
                thumbnailURL = FlickrFetcher.URLforPhoto(photo, format: .Square),
                photographer = photo[FlickrFetcher.Constants.FLICKR_PHOTO_OWNER] as? String else {
                    return
            }

            if var photosBelongsTo = self.photographers[photographer] {
                photosBelongsTo.append(Photo.init(unique: unique, title: title, subtitle: photo[FlickrFetcher.Constants.FLICKR_PHOTO_DESCRIPTION] as? String, owner: photographer, thumbnailURL: thumbnailURL, imageURL: imageURL))
                self.photographers[photographer] = photosBelongsTo
            } else {
                self.photographers[photographer] = [Photo.init(unique: unique, title: title, subtitle: photo[FlickrFetcher.Constants.FLICKR_PHOTO_DESCRIPTION] as? String, owner: photographer, thumbnailURL: thumbnailURL, imageURL: imageURL)]
            }
        }
        NSNotificationCenter.defaultCenter().postNotificationName(FlickrInfoDownloaded, object: self)
    }


    // REVIEW: Please group the methods in a certain area

    class func beginDownloadImages(photos: [Photo], usingBlock: (UIImage?, NSURL?) -> Void) {
        // REVIEW: If no change in var, use let or empty it in this case.
        for photoInfo in photos {
            downloadImage(photoInfo.thumbnailURL, usingBlock: { (image) -> Void in
                usingBlock(image, photoInfo.imageURL)
            })
        }
    }

    class func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

    class func downloadImage(url: NSURL, usingBlock: (UIImage?) -> Void) {
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else {
                    return
                }
                usingBlock(UIImage(data: data))
            }
        }
    }

}
