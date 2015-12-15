//
//  FlickrModel.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 3/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

let FlickrInfoDownloaded = "FlickrInfoDownloadComplete"
let FlickrPhoto = "FlickrPhoto"


extension Array where Element: Equatable{
    mutating func removeObject(object: Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

// REVIEW: What is the use of this class?
// prepare(fetch) the data for controllers
class FlickrModel {
    // REVIEW: If photographer is an array, please use plural.
    var photographers = [Photographer]()
    var mySession = NSURLSession.self

    init() {
        fetch()
    }

    func fetch() {
        let session = mySession.sharedSession()
        let request = NSURLRequest(URL: FlickrFetcher.URLforRecentGeoreferencedPhotos()!)
//        let task = session.downloadTaskWithRequest(request) { (localFile, response, error) -> Void in
//            if let e = error {
//                print("Flickr background fetch failed: \(e.localizedDescription)")
//            } else {
//                if let photos = self.flickrPhotosAtURL(localFile!) {
//                    self.loadImagesFromFlickrArray(photos)
//                }
//            }
//        }
        let task = session.dataTaskWithRequest(request) { (flickrJSONData, response, error) -> Void in
            var jsonResult: [String: AnyObject]?
            do {
                jsonResult = try NSJSONSerialization.JSONObjectWithData(flickrJSONData!, options: []) as? [String: AnyObject]
            } catch let e as NSError {
                print("Flickr fetch failed: \(e)")
            }
            // REVIEW: Please use `[[String: AnyObject]]` instead of `Array<[String: AnyObject]>`
            let photos = jsonResult!["photos"]!
            if let p = photos["photo"] as? [[String: AnyObject]] {
                self.loadImagesFromFlickrArray(p)
            }
        }
        task.resume()
    }


//    func flickrPhotosAtURL(URL: NSURL) -> [[String: AnyObject]]? {
//        guard let flickrJSONData = NSData(contentsOfURL: URL) else {
//            return nil
//        }
//        var jsonResult: [String: AnyObject]
//        do {
//            jsonResult = try NSJSONSerialization.JSONObjectWithData(flickrJSONData, options: []) as! [String: AnyObject]
//        } catch let e as NSError {
//            print("\(e)")
//            return nil
//        }
//        // REVIEW: Please use `[[String: AnyObject]]` instead of `Array<[String: AnyObject]>`
//        let photos = jsonResult["photos"]!
//        return photos["photo"] as? [[String: AnyObject]]
//    }

    private func loadImagesFromFlickrArray(photos: [[String: AnyObject]]) {
        for photo in photos {
            // REVIEW: Too many `if let`, please use `guard let` instead.

            guard let photographer = photo[FlickrFetcher.Constants.FLICKR_PHOTO_OWNER] as? String, let newPhoto = Photo(photo: photo) else {
                    continue
            }

            let filteredPhotographers = photographers.filter() { $0.name == photographer }

            guard var photosBelongsTo = filteredPhotographers.first?.photos where photosBelongsTo.count > 0 else {
                photographers.append(Photographer(name: photographer, photos: [newPhoto]))
                continue
            }
            photographers.removeObject(filteredPhotographers.first!)
            photosBelongsTo.append(newPhoto)
            photographers.append(Photographer(name: photographer, photos: photosBelongsTo))
        }
        NSNotificationCenter.defaultCenter().postNotificationName(FlickrInfoDownloaded, object: self)
    }
}