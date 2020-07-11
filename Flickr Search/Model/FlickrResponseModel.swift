//
//  FlickrResponseModel.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 10/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import Foundation

class Photos: Codable {
    let photos: PhotosClass
}

class PhotosClass: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

class Photo: Codable, PhotoURL {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}

protocol PhotoURL {}

extension PhotoURL where Self == Photo{
    
    func getImagePath() -> URL?{
        let path = "http://farm\(self.farm).static.flickr.com/\(self.server)/\(self.id)_\(self.secret).jpg"
        return URL(string: path)
    }
    
}

