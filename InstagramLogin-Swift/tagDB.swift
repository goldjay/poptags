//
//  tagDB.swift
//  InstagramLogin-Swift
//
//  Created by Jay Steingold on 6/4/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import Foundation
import SQLite

class TagDB {
    
    static let instance = TagDB()
    private let db: Connection?
    
    private let tagsTable = Table("tagsTable")
    private let id = Expression<Int64>("id")
    private let name = Expression<String>("name")
    private let queryString = Expression<String>("queryString")
    private let tagString = Expression<String>("tagString")
    
    private init() {
        let path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            db = try Connection("\(path)/tagDB.sqlite3")
        } catch {
            db = nil
            print ("Unable to open database")
        }
        //print("NOW CREATE A TABLE METHOD!")
        createTable()
    }
    
    func createTable() {
        do {
            try db!.run(tagsTable.create(ifNotExists: true) { table in
                table.column(id, primaryKey: true)
                table.column(name)
                table.column(queryString)
                table.column(tagString)
            })
        } catch {
            print("Unable to create table")
        }
    }
    
    func addTags(uQuery: String, uTag: String) -> Int64? {
        do {
            let insert = tagsTable.insert(queryString <- uQuery, tagString <- uTag, name <- currentUser)
            let id = try db!.run(insert)
            
            return id
        } catch {
            print("Insert failed")
            return -1
        }
    }
    
    func getTags() -> [SavedTag] {
        var savedTags = [SavedTag]()
        
        do {
            for tag in try db!.prepare(self.tagsTable) {
                savedTags.append(SavedTag(id: tag[id],
                                          queryString: tag[queryString],
                                          tagString: tag[tagString],
                                          name: tag[name]))
            }
        } catch {
            print("Select failed")
        }
        return savedTags
    }
    
    func deleteTag(cid: Int64) -> Bool {
    do {
        let item = tagsTable.filter(id == cid)
        try db!.run(item.delete())
        return true
    } catch {
        print("Delete failed")
    }
    return false
    }
    
    func updateTag(cid: Int64, newTag: SavedTag) -> Bool {
        let tag = tagsTable.filter(id == cid)
        do {
            let update = tag.update([
                queryString <- newTag.queryString,
                tagString <- newTag.tagString
            ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        return false 
    }
}
