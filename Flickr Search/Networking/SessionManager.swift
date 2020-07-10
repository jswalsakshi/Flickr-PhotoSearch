//
//  SessionManager.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 10/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import UIKit

class SessionManager: NSObject {
    
    static let sharedInstance = SessionManager()
    let flickrKey = "a2b2783c63360f21f955cfed0dd57b61"
    
    func getServerData(searchText: String,
                       pageCount: Int,
                       completionHandler: @escaping
        (_ success: Bool,_ error: Error?, _ response: Photos?, _ data: Data?) -> Void) {
        
        guard let url = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrKey)&format=json&nojsoncallback=1&safe_search=\(pageCount)&text=\(searchText)") else {
            print("Invalid URL")
            return
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let decodedResponse = try? JSONDecoder().decode(Photos.self, from: data) {
                    DispatchQueue.main.async {
                        completionHandler(true, error, decodedResponse, data)
                        
                    }
                    return
                }
            }
            print("Failed to load Data: \(error?.localizedDescription ?? "Unknown error")")
        }.resume()
    }
}
