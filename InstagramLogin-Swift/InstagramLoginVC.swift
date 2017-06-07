//
//  InstagramLoginVC.swift
//  InstagramLogin-Swift
//
//  Created by Aman Aggarwal on 2/7/17.
//  Copyright © 2017 ClickApps. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class InstagramLoginVC: UIViewController, UIWebViewDelegate, UITextViewDelegate {

    @IBOutlet weak var loginWebView: UIWebView!
    @IBOutlet weak var loginIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var largeTextField: UITextView!
    
    var authToken: String = "" {
        didSet {
            loginWebView.isHidden = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        loginWebView.delegate = self
        unSignedRequest()
        
        largeTextField.delegate = self
        
        loginWebView.layer.zPosition = 2
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loginWebView.delegate = self
        unSignedRequest()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - unSignedRequest
    func unSignedRequest () {
        let authURL = String(format: "%@?client_id=%@&redirect_uri=%@&response_type=token&scope=%@&DEBUG=True", arguments: [INSTAGRAM_IDS.INSTAGRAM_AUTHURL,INSTAGRAM_IDS.INSTAGRAM_CLIENT_ID,INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI, INSTAGRAM_IDS.INSTAGRAM_SCOPE ])
        let urlRequest =  URLRequest.init(url: URL.init(string: authURL)!)
        loginWebView.loadRequest(urlRequest)
    }

    func checkRequestForCallbackURL(request: URLRequest) -> Bool {
        
        let requestURLString = (request.url?.absoluteString)! as String
        
        if requestURLString.hasPrefix(INSTAGRAM_IDS.INSTAGRAM_REDIRECT_URI) {
            let range: Range<String.Index> = requestURLString.range(of: "#access_token=")!
            handleAuth(authToken: requestURLString.substring(from: range.upperBound))
            return false;
        }
        return true
    }
    
    func logOutRequest() {
        let urlRequest =  URLRequest.init(url: URL.init(string: INSTAGRAM_IDS.INSTAGRAM_LOGOUTURL)!)
        loginWebView.reload()
        loginWebView.loadRequest(urlRequest)
    }
    
    func handleAuth(authToken: String)  {
        print("Instagram authentication token ==", authToken)
        self.authToken = authToken
        
        _ = ["access_token": authToken]
        
        // GET the userName
            Alamofire.request("https://api.instagram.com/v1/users/self/?access_token=" + authToken, parameters: nil).responseJSON { response in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    currentUser = (JSON(data: response.data!)["data"]["username"]).stringValue
                    print("THE CURRENT USER IS \(currentUser)")
                }
                break
                
            case .failure(_):
                print(response.result.error)
                break
                
            }
        }
    }
    
    
    
    // MARK: - UIWebViewDelegate
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        return checkRequestForCallbackURL(request: request)
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = false
        loginIndicator.startAnimating()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        loginIndicator.isHidden = true
        loginIndicator.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        webViewDidFinishLoad(webView)
    }

    @IBAction func handleSearchButton(_ sender: UIButton) {
        var tagString = ""
        
        if let qString = textField.text {
            let parameters = ["q": qString, "access_token": authToken]
            Alamofire.request("https://api.instagram.com/v1/tags/search", parameters: parameters).responseJSON { response in
                print(response)
                
                let data = JSON(data: response.data!)["data"]
                
                let resultsArray = data.arrayValue
                
                let sortedResults = resultsArray.sorted { $0["media_count"].doubleValue > $1["media_count"].doubleValue }
                
                print(sortedResults)
                
                // Convert array to a string value and add it to textDisplay field
                for item in sortedResults {
                    let temp = item["name"].stringValue
                    tagString += ("#" + temp + " ")
                }
                self.largeTextField.text = tagString
            }
        }
    }
    @IBAction func handleIGLogout(_ sender: UIButton) {
        logOutRequest()
    }
    @IBAction func handleSaveTag(_ sender: UIButton) {
        
        var unique = true
        
        if let qString = textField.text {
            let tString = largeTextField.text
         
            //Check if one already exists
            for item in tags {
                if item.queryString == qString && item.name == currentUser {
                    let alertController = UIAlertController(title: "Error", message: "This tag already exists", preferredStyle: .alert)
                    
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
                        print("You've pressed OK button");
                    }
                    
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true, completion:nil)
                    unique = false
                }
            }
            
            if unique == true {
                
                print(TagDB.instance.addTags(uQuery: qString, uTag: tString!))
                
                /*
                if((TagDB.instance.addTags(uQuery: qString, uTag: tString!)) != nil){
                    print("Successfully added a tag!")
                }
                */
                
                tags = TagDB.instance.getTags()
                print(tags)
            }
            
        }
        
    }

}
