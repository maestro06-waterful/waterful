//
//  DataSource.swift
//  waterful_watch Extension
//
//  Created by suz on 10/9/15.
//  Copyright © 2015 suz. All rights reserved.
//


struct DataSource {
    
    var item: Item
    
    enum Item {
        case consumed(Double)
        case goal(Double)
        case Unknown
    }
    
    init(data: [String : AnyObject]) {
        if let consumed = data["consumed"] as? Double {
            item = Item.consumed(consumed)
        }
        if let goal = data["goal"] as? Double{
            item = Item.goal(goal)
        }
        else {
            item = Item.Unknown
        }
        
    }
}
