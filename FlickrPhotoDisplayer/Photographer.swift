//
//  Photographer.swift
//  FlickrPhotoDisplayer
//
//  Created by Harry on 10/12/2015.
//  Copyright © 2015 Snaptee. All rights reserved.
//

import Foundation

struct Photographer: Equatable {
    var name: String
    var photos: [Photo]

    init(name: String, photos: [Photo]) {
        self.name = name
        self.photos = photos
    }
}

func == (lhs:Photographer, rhs:Photographer) -> Bool {
    return lhs.name == rhs.name
}