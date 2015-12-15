//
//  FlickrFetcher.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 4/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

// REVIEW: you deleted the key in  FlickrAPIKey.h but not here...


// REVIEW: Constants can be placed inside the class with a struct called Constants.
//         You can use extension to exten the class to store those constants if they are too much.
//         You can also save them in different struct to categorize them.
extension FlickrFetcher{
    struct Constants {
        static let FlickrAPIKey = "f3333822775812370a74dc8e72034ad9"


        // key paths to photos or places at top-level of Flickr results
        static let FLICKR_RESULTS_PHOTOS = "photos.photo"
        static let FLICKR_RESULTS_PLACES = "places.place"

        // keys (paths) to values in a photo dictionary
        static let FLICKR_PHOTO_TITLE = "title"
        static let FLICKR_PHOTO_DESCRIPTION = "description._content"
        static let FLICKR_PHOTO_ID = "id"
        static let FLICKR_PHOTO_OWNER = "ownername"
        static let FLICKR_PHOTO_UPLOAD_DATE = "dateupload" // in seconds since 1970
        static let FLICKR_PHOTO_PLACE_ID = "place_id"

        // keys (paths) to values in a places dictionary (from TopPlaces)
        static let FLICKR_PLACE_NAME = "_content"
        static let FLICKR_PLACE_ID = "place_id"

        // keys applicable to all types of Flickr dictionaries
        static let FLICKR_LATITUDE = "latitude"
        static let FLICKR_LONGITUDE = "longitude"
        static let FLICKR_TAGS = "tags"


        static let FLICKR_PLACE_NEIGHBORHOOD_NAME = "place.neighbourhood._content"
        static let FLICKR_PLACE_NEIGHBORHOOD_PLACE_ID = "place.neighbourhood.place_id"
        static let FLICKR_PLACE_LOCALITY_NAME = "place.locality._content"
        static let FLICKR_PLACE_LOCALITY_PLACE_ID = "place.locality.place_id"
        static let FLICKR_PLACE_REGION_NAME = "place.region._content"
        static let FLICKR_PLACE_REGION_PLACE_ID = "place.region.place_id"
        static let FLICKR_PLACE_COUNTY_NAME = "place.county._content"
        static let FLICKR_PLACE_COUNTY_PLACE_ID = "place.county.place_id"
        static let FLICKR_PLACE_COUNTRY_NAME = "place.country._content"
        static let FLICKR_PLACE_COUNTRY_PLACE_ID = "place.country.place_id"
        static let FLICKR_PLACE_REGION = "place.region"
    }
}

class FlickrFetcher {

    // REVIEW: So as enum, can locate within the class to act namespaced MVC
    enum FlickrPhotoFormat: Int {
        // REVIEW: No need to repeat `FlickrPhotoFormat`
        case Square = 1    // thumbnail
        case Large = 2     // normal size
        case Original = 64  // high resolution

        func formatString() -> String {
            switch self {
            case .Square:
                return "s"
            case .Large:
                return "b"
            case .Original:
                return "o"
            }
        }
    }

    // REVIEW: The URL prefix are all the same in `"https://api.flickr.com/services/rest/"`,
    //         why not make them in this function?
    //         Besides, how do you make sure the `query` parameter has `"?"` already?
    class func URLForQuery(query: String) -> NSURL? {
        let components = NSURLComponents()
        components.scheme = "https"
        components.host = "api.flickr.com"
        components.path = "/services/rest/?\(query)"
        components.queryItems = [NSURLQueryItem(name: "format", value: "json"), NSURLQueryItem(name: "nojsoncallback", value: "1"), NSURLQueryItem(name: "api_key", value: Constants.FlickrAPIKey)]
        var q = "https://api.flickr.com/services/rest/?\(query)&format=json&nojsoncallback=1&api_key=\(Constants.FlickrAPIKey)"
        q = q.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        // REVIEW: no Need to write `init`, just use `NSURL(string: q)`
        print(components.URL?.absoluteString)
        print(q)
//        return components.URL
        return NSURL(string: q)
    }

    class func URLforTopPlaces() -> NSURL? {
        return URLForQuery("method=flickr.places.getTopPlacesList&place_type_id=7")
    }

    class func URLforPhotosInPlace(flickrPlaceId placeID: String, maxResults max: Int) -> NSURL? {
        return URLForQuery("method=flickr.photos.search&place_id=\(placeID)&per_page=\(max)&extras=original_format,tags,description,geo,date_upload,owner_name,place_url")
    }

    class func URLforRecentGeoreferencedPhotos() -> NSURL? {
        return URLForQuery("method=flickr.photos.search&license=1,2,4,7&has_geo=1&extras=original_format,description,geo,date_upload,owner_name")
    }

    // REVIEW: Just use [String: AnyObject] instead of Dictionary<String, AnyObject>,
    //         or use a Photo struct/class may be better
    class func URLStringForPhoto(photo: [String: AnyObject], format: FlickrPhotoFormat) -> String? {
        let farm = photo["farm"]
        let server = photo["server"]
        let photo_id = photo["id"]
        var secret = photo["secret"]
        var fileType: AnyObject = "jpg"
        if format == .Original {
            secret = photo["originalsecret"]
            fileType = photo["originalformat"]!
        }

        guard (farm != nil && server != nil && photo_id != nil && secret != nil) else {
            return nil
        }

        // REVIEW: Just add a function to the enum so you can just use the enum value to get the string
        let formatString = format.formatString()

        return "https://farm\(farm!).static.flickr.com/\(server!)/\(photo_id!)_\(secret!)_\(formatString).\(fileType)"
    }

    class func URLforPhoto(photo: [String: AnyObject],format: FlickrPhotoFormat) -> NSURL? {
        guard let URL =  URLStringForPhoto(photo, format: format) else {
            return nil
        }
        return NSURL.init(string: URL)
    }

    class func URLforInformationAboutPlace(flickrPlaceId: AnyObject) -> NSURL? {
        return URLForQuery("method=flickr.places.getInfo&place_id=\(flickrPlaceId)")
    }

    func extractNameOfPlace(placeId: String, fromPlaceInformation place: [String: String]) -> String? {
        var name: String?

        switch placeId {
        case place[Constants.FLICKR_PLACE_NEIGHBORHOOD_PLACE_ID]!:
            name = place["FLICKR_PLACE_NEIGHBORHOOD_NAME"]
        case place[Constants.FLICKR_PLACE_LOCALITY_PLACE_ID]!:
            name = place["FLICKR_PLACE_LOCALITY_NAME"]
        case place[Constants.FLICKR_PLACE_COUNTY_PLACE_ID]!:
            name = place["FLICKR_PLACE_COUNTY_NAME"]
        case place[Constants.FLICKR_PLACE_REGION_PLACE_ID]!:
            name = place["FLICKR_PLACE_REGION_NAME"]
        case place[Constants.FLICKR_PLACE_COUNTRY_PLACE_ID]!:
            name = place["FLICKR_PLACE_COUNTRY_NAME"]
        default:
            name = nil
        }
        return name
    }

    class func extractRegionNameFromPlaceInformation(place: [String: String]) -> String {
        return place[Constants.FLICKR_PLACE_REGION_NAME]!
    }

}
