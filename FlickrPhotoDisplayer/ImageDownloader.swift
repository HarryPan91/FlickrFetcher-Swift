//
//  ImageDownloader.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 10/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
    // REVIEW: Please group the methods in a certain area

    static let imageCacher = NSCache()

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
        if let image = imageCacher.objectForKey(url.absoluteString) {
            usingBlock((image as! UIImage))
        } else {
            getDataFromUrl(url) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil, let image = UIImage(data: data) else {
                        return
                    }
                    imageCacher.setObject(image, forKey: url.absoluteString)
                    usingBlock(image)
                }
            }
        }
    }
}