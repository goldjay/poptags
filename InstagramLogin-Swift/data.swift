//
//  data.swift
//  InstagramLogin-Swift
//
//  Created by Jay Steingold on 6/5/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import Foundation
import SQLite



var tags = TagDB.instance.getTags()
var currentUser: String = ""
