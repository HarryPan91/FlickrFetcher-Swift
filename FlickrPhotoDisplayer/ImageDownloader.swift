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

    typealias CallbackType = (UIImage?) -> Void
    static let imageCacher = NSCache()
    static var imageWithCallbackBlocks = [String: [CallbackType]]()

    class func beginDownloadImages(photos: [Photo], usingBlock completion: (UIImage?, NSURL?) -> Void) {
        // REVIEW: If no change in var, use let or empty it in this case.
        for photoInfo in photos {
            downloadImage(photoInfo.thumbnailURL, usingBlock: { (image) -> Void in
                completion(image, photoInfo.imageURL)
            })
        }
    }

    class func getDataFromURL(URL: NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        NSURLSession.sharedSession().dataTaskWithURL(URL) { (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }

    class func downloadImage(URL: NSURL, usingBlock completion: CallbackType) {

        if let image = imageCacher.objectForKey(URL.absoluteString) {
            completion((image as! UIImage))
        } else {

            if var cachedCallBackBlocks = imageWithCallbackBlocks[URL.absoluteString] {
                cachedCallBackBlocks.append(completion)
                imageWithCallbackBlocks[URL.absoluteString] = cachedCallBackBlocks
                return
            } else {
                imageWithCallbackBlocks[URL.absoluteString] = [completion]
            }

            getDataFromURL(URL) { (data, response, error)  in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    guard let data = data where error == nil, let image = UIImage(data: data) else {
                        return
                    }
                    imageCacher.setObject(image, forKey: URL.absoluteString)

                    for completion in imageWithCallbackBlocks[URL.absoluteString]! {
                        completion(image)
                    }
                    imageWithCallbackBlocks.removeValueForKey(URL.absoluteString)
                }
            }
        }
    }
}