//
//  Item.swift
//  (18) Todoey - Core Data, Realm, User Defaults
//
//  Created by Amy Fang on 7/3/19.
//  Copyright © 2019 Amy Fang. All rights reserved.
//

import Foundation

// allows the class to be encodable & decodable or in a plist/json file
// only classes that have variables with standard data types can be encoded
class Item: Codable {
    var title:String = ""
    var done:Bool = false
}
