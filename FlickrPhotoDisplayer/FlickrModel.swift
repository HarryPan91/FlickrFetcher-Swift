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
    private var photographers = [Photographer]()
    var session = NSURLSession.sharedSession()

//    init() {
//        fetch(){}
//    }

    func fetch(completion: ([Photographer]) -> Void) {

        print(FlickrFetcher.URLforRecentGeoreferencedPhotos()!)
        let request = NSURLRequest(URL: FlickrFetcher.URLforRecentGeoreferencedPhotos()!)
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            var jsonResult: [String: AnyObject]?
            guard let flickrJSONData = data where error == nil else {
                return
            }
            do {
                jsonResult = try NSJSONSerialization.JSONObjectWithData(flickrJSONData, options: []) as? [String: AnyObject]
            } catch let e as NSError {
                print("Flickr fetch failed: \(e)")
                self.photographers = [Photographer]()
                completion(self.photographers)
                return
            }
            // REVIEW: Please use `[[String: AnyObject]]` instead of `Array<[String: AnyObject]>`
            guard let photos = jsonResult?["photos"] else {
                return
            }
            if let p = photos["photo"] as? [[String: AnyObject]] {
                self.loadImagesFromFlickrArray(p)
            }
            completion(self.photographers)
        }
        task.resume()
    }

    func reload(completion: ([Photographer]) -> Void) {
        photographers.removeAll()
        fetch(completion)
    }

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
    }
}