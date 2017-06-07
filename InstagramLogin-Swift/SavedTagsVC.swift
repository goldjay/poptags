//
//  SavedTagsVC.swift
//  InstagramLogin-Swift
//
//  Created by Jay Steingold on 6/4/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import UIKit

class SavedTagsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var selectedTag: Int?
    
    var userTags = [SavedTag]()
    

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        userTags = tags.filter{ $0.name == currentUser }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTag = indexPath.row
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTags.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 200
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        let item = userTags[(indexPath.row)]
        
        if editingStyle == .delete {
            if(TagDB.instance.deleteTag(cid: item.id!)){
                tags = TagDB.instance.getTags()
                userTags = tags.filter{ $0.name == currentUser }
                tableView.reloadData()
            } else {
                print("Could not delete the tag!")
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell")!
        
        var label: UILabel
        label = cell.viewWithTag(1) as! UILabel
        label.text = userTags[indexPath.row].queryString
        
        var tv: UITextView
        tv = cell.viewWithTag(2) as! UITextView
        tv.text = userTags[indexPath.row].tagString
        
        //Assign action to update button
        var btn: UIButton
        btn = cell.viewWithTag(3) as! UIButton
        btn.addTarget(self, action: #selector(buttonSave), for: .touchUpInside)
        
        return cell
    }
    
    func buttonSave(sender: UIButton) {
        let cell = sender.superview?.superview as! UITableViewCell
        
        let label = cell.viewWithTag(1) as! UILabel
        let tv = cell.viewWithTag(2) as! UITextView
        
        // Search through userTags for the title
        for item in userTags {
            if item.queryString == label.text && item.name == currentUser {
                let cid = item.id
                
                let newTag = SavedTag(id: item.id!, queryString: label.text!, tagString: tv.text, name: item.name)
                
                if(TagDB.instance.updateTag(cid: cid!, newTag: newTag)){
                    print("Successfully updated!")
                }
                tags = TagDB.instance.getTags()
            }
        }
    }
    
    @IBAction func handleEditTags(_ sender: UIButton) {
        tableView.isEditing = true
    }
}
