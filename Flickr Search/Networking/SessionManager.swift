//
//  SessionManager.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 10/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import Foundation

class SessionManager{
    
    let defaultSession = URLSession(configuration: .default)
    
    var dataTask: URLSessionDataTask?
    var errorMessage = ""
    var photos: [Photo] = []
    
    typealias JSONDictionary = [String: Any]
    typealias QueryResult = ([Photo]?, String) -> Void
    
    let flickrKey = "a2b2783c63360f21f955cfed0dd57b61"
    
    func getSearchResults(searchText: String, pageCount: Int, completion: @escaping QueryResult) {
        // 1
        dataTask?.cancel()
        
        // 2
        if var urlComponents = URLComponents(string: "https://api.flickr.com/services/rest") {
            urlComponents.query = "method=flickr.photos.search&api_key=\(flickrKey)&format=json&nojsoncallback=1&safe_search=\(pageCount)&text=\(searchText)"
            
            // 3
            guard let url = urlComponents.url else {
                return
            }
            
            // 4
            dataTask = defaultSession.dataTask(with: url) { [weak self] data, response, error in
                defer {
                    self?.dataTask = nil
                }
                
                // 5
                if let error = error {
                    self?.errorMessage += "DataTask error: " + error.localizedDescription + "\n"
                } else if
                    let data = data,
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 {
                    
                    self?.updateSearchResults(data)
                    
                    // 6
                    DispatchQueue.main.async {
                        completion(self?.photos, self?.errorMessage ?? "")
                    }
                }
            }
            
            // 7
            dataTask?.resume()
        }
    }
    
    private func updateSearchResults(_ data: Data) {
        var response: JSONDictionary?
        photos.removeAll()
        
        do {
            response = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
        } catch let parseError as NSError {
            errorMessage += "JSONSerialization error: \(parseError.localizedDescription)\n"
            return
        }
        guard let array = response!["response"] as? [Any] else {
            errorMessage += "Dictionary does not contain results key\n"
            return
        }
        
        array.forEach({ (photo) in
            self.photos.append(photo as! Photo)
        })
        
        
       // var index = 0
        
        //for trackDictionary in array {
//            if let trackDictionary = trackDictionary as? JSONDictionary,
//                let previewURLString = trackDictionary["previewUrl"] as? String,
//                let previewURL = URL(string: previewURLString),
//                let name = trackDictionary["trackName"] as? String,
//                let artist = trackDictionary["artistName"] as? String {
//                tracks.append(Track(name: name, artist: artist, previewURL: previewURL, index: index))
//                index += 1
//            } else {
//                errorMessage += "Problem parsing trackDictionary\n"
//            }
        }
    }

