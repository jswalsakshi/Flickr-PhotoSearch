//
//  paging.swift
//  Flickr Search
//
//  Created by Sakshi Jaiswal on 12/07/20.
//  Copyright © 2020 Sakshi Jaiswal. All rights reserved.
//

import Foundation

class Paging {
    
    var totalPages: Int?
    var numberOfElements: Int32?
    var currentSize: Int = 20
    var currentPage: Int?
    
    init(totalPages: Int, elements: Int32, currentPage: Int) {
        self.totalPages = totalPages
        self.numberOfElements = elements
        self.currentPage = currentPage
    }
}

