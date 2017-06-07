//
//  savedTags.swift
//  InstagramLogin-Swift
//
//  Created by Jay Steingold on 6/4/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import Foundation

class SavedTag {
    var id: Int64? = nil
    var queryString: String
    var tagString: String
    var name: String
    
    init(id: Int64) {
        self.id = id
        queryString = ""
        tagString = ""
        name = ""
    }
    
    init(id: Int64, queryString: String, tagString: String, name: String) {
        self.id = id
        self.queryString = queryString
        self.tagString = tagString
        self.name = name
    }
}
