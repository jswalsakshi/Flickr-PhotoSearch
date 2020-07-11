//
//  ImageProvider.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 11/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import UIKit


class ImageProvider: RequestImages {
    
    fileprivate let downloadQueue = DispatchQueue(label: "Images cache", qos: DispatchQoS.background)
    internal var cache = NSCache<NSURL, UIImage>()

    
    //MARK: - Fetch image from URL and Images cache
    fileprivate func loadImages(from url: URL, completion: @escaping (_ image: UIImage) -> Void) {
        downloadQueue.async(execute: { () -> Void in
            if let image = self.cache.object(forKey: url as NSURL) {
                DispatchQueue.main.async {
                    completion(image)
                }
                return
            }
            
            do{
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.cache.setObject(image, forKey: url as NSURL)
                        completion(image)
                    }
                } else {
                    print("Could not decode image")
                }
            }catch {
                print("Could not load URL: \(url): \(error)")
            }
        })
    }
    
}

protocol RequestImages {}

extension RequestImages where Self == ImageProvider{
    func requestImage(from url: URL, completion: @escaping (_ image: UIImage) -> Void){
        self.loadImages(from: url, completion: completion)
    }
}
