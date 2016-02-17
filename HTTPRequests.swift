//
//  HTTPRequests.swift
//
//  Created by Luciano Bohrer on 1/19/16.
//

import UIKit
import Foundation

/*
    Manager for HTTP requests such as POST and GET from https://medium.com/swift-programming/http-in-swift-693b3a7bf086#.kjh57aq9v

    Adapted for my needs...

    Example of request
    
    func testCreateCustomerParams() -> Void {
        let action = "user/login"
        let parameters : [String : AnyObject] = [
        "user":        "admin",
        "password":     "shgdklajhs7283=="
        ]

        httpOperation.HTTPPostJSON(BASE_URL + action, jsonObj: parameters) {
        (data: String, error: String?) in

            if error != nil{
                self.handleError(self.httpOperation.JSONParseDict(data))
            }else{
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.successCase()
                })
            }
        }
    }


*/



class HTTPRequests: NSObject {

    func JSONParseDict(jsonString:String) -> Dictionary<String, AnyObject> {
        
        if let data: NSData = jsonString.dataUsingEncoding(
            NSUTF8StringEncoding){
                
                do{
                    if let jsonObj = try NSJSONSerialization.JSONObjectWithData(
                        data,
                        options: NSJSONReadingOptions(rawValue: 0)) as? Dictionary<String, AnyObject>{
                            return jsonObj
                    }
                }catch{
                    print("Error")
                }
        }
        return [String: AnyObject]()
    }
    
    func HTTPsendRequest(request: NSMutableURLRequest,
        callback: (String, String?) -> Void) {
            
            let task = NSURLSession.sharedSession().dataTaskWithRequest(
                request, completionHandler :
                {
                    data, response, error in
                    var flag = false
                    if let httpResponse = response as? NSHTTPURLResponse {
                        if httpResponse.statusCode != 200 && httpResponse.statusCode != 204{
                            flag = true
                        }
                    }
                    if error != nil || flag == true{
                        if let message = NSString(data: data!, encoding: NSUTF8StringEncoding) as? String{
                            if error != nil{
                                callback(message, (error!.localizedDescription) as String)
                            }else{
                                callback(message, "Error")
                            }
                        }else{
                            callback("", (error!.localizedDescription) as String)
                        }
                    } else {
                        callback(
                            NSString(data: data!, encoding: NSUTF8StringEncoding) as! String,
                            nil
                        )
                    }
            })
            
            task.resume()
            
    }
    
    func HTTPGetJSON(
        url: String,
        callback: (Dictionary<String, AnyObject>, String?) -> Void) {
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            HTTPsendRequest(request) {
                (data: String, error: String?) -> Void in
                if error != nil {
                    callback(Dictionary<String, AnyObject>(), error)
                } else {
                    let jsonObj = self.JSONParseDict(data)
                    callback(jsonObj, nil)
                }
            }
    }

    
    func HTTPPostJSON(url: String,
        jsonObj: AnyObject,
        callback: (String, String?) -> Void) {
            
            let request = NSMutableURLRequest(URL: NSURL(string: url)!)
            request.HTTPMethod = "POST"
            request.addValue("application/json",
                forHTTPHeaderField: "Content-Type")
            let jsonString = JSONStringify(jsonObj)
            let data: NSData = jsonString.dataUsingEncoding(
                NSUTF8StringEncoding)!
            request.HTTPBody = data
            HTTPsendRequest(request,callback: callback)
    }
    

    
    
    // Author - Santosh Rajan
    func JSONStringify(value: AnyObject, prettyPrinted : Bool = false) -> String{
        
        let options = prettyPrinted ? NSJSONWritingOptions.PrettyPrinted : NSJSONWritingOptions(rawValue: 0)
        
        
        if NSJSONSerialization.isValidJSONObject(value) {
            
            do{
                let data = try NSJSONSerialization.dataWithJSONObject(value, options: options)
                if let string = NSString(data: data, encoding: NSUTF8StringEncoding) {
                    return string as String
                }
            }catch {
                
                print("error")
                //Access error here
            }
            
        }
        return ""
        
    }
}
