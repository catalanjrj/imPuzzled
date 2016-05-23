//
//  APIData.swift
//  Puzzle
//
//  Created by Tom Williamson on 5/17/16.
//  Copyright © 2016 Tom Williamson. All rights reserved.
//

import UIKit

protocol APIDataDelegate: class {
    
    func gotAPIData(apidata: APIData)
    
}


class APIData: NSObject,NSURLSessionDelegate {
    
    var delegate: APIDataDelegate?
    
    var request: String?
    var rawData: NSData?
    var dictionary: AnyObject?
    var errorText: String?
    var userField: String?
    var userType: Int?
    
    
    //
    //  start an api request
    //
    init(request: String, delegate: APIDataDelegate) {
        
        super.init()
        
        self.request = request;
        self.delegate = delegate;
        
        if !request.hasPrefix("https://") {self.request = "https://" + request }
        
        let url = NSURL.init(string: self.request!)
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: url!)
        let session = NSURLSession(configuration: .defaultSessionConfiguration(), delegate: nil, delegateQueue: NSOperationQueue.mainQueue())
        
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                self.gotData(data!)
            }
        }
    
        task.resume()
        
    }
    
    
    //
    //  we have data back
    //
    func gotData(data: NSData) {
        
        if data.length > 0 {
            rawData = data
            do {
                self.dictionary = try NSJSONSerialization.JSONObjectWithData(data, options:.AllowFragments)
            }
            catch {
            }
            
            if delegate != nil {
                delegate!.gotAPIData(self)
            }
            
        }
    }
    
}
