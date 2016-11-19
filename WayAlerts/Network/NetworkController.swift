//
//  NetworkController.swift
//  WayAlerts
//
//  Created by Hari Kishore on 6/9/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit

class NetworkController: NSObject {
    
    static let sharedInstance = NetworkController()
    let ncHelper = NetworkControllerHelper.sharedInstance;

    
        func loadRequest(request : NSMutableURLRequest, Params params : Dictionary<String, String>, Success success:(responseData : NSDictionary)->(), Failure failure:(error : NSError) -> ()) {
        let session = NSURLSession.sharedSession()
            
        request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(params, options:[])
        //request.HTTPBody = (params as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request, completionHandler: {
            data, response, error -> Void in
            
            if error != nil{
                failure(error: error!)
                return
            } else {
                //Convert the JSON result to a dictionary obj and return
                let responseDict = self.getResponseDict(data!);
                //success(responseData: data!)
                success(responseData: responseDict)
                
            }
        })
        
        task.resume()
    }
    
    func getResponseDict(data:NSData) -> NSDictionary{
        // Converts the JSON response to dictionary
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as! [String:AnyObject];
        } catch let error as NSError {
            print(error)
        }
        return NSDictionary();
    }
    
//    func placeServerRequestOld(Params postRequestBody : Dictionary<String, String>, Success success:(responseData : NSDictionary)->(), Failure failure:(error : NSError) -> ()) {
//        self.loadRequest(requestWithURl(Constants.waRequestURL), Params: postRequestBody, Success: { (data) in
//            success(responseData: data as! Dictionary<String, AnyObject>)
//        }) { (error) in
//            //print(error)
//            failure(error: error)
//        }
//        
//    }
    
    func placeServerRequest(RequestName requestName: String, APISpecificParams apiSpecificParams: Dictionary<String, String>, Success success:(responseData : Dictionary<String, AnyObject>)->(), Failure failure:(error : NSError) -> ()) {
        
        // Check to see if device is connected too internet
        let isConnectedToNetwork = Utils.isConnectedToNetwork()
        if (!isConnectedToNetwork){
            //print("Internet connection not available")
            
            Utils.showAlertOK(Title: StringConstants.noInternetAlertTitle,Message: StringConstants.noInternetAlertDesc)
            
//            let alert = UIAlertView(title: "No Internet connection", message: "Please ensure you are connected to the Internet", delegate: nil, cancelButtonTitle: "OK")
//            alert.show()
            return
        }
        
        // Get the post request body from apiSpecificParams
        let postRequestBody = ncHelper.getAPIRequestDict(requestName, requestParameters: apiSpecificParams);
        
        // Now place server request
        //Constants.Generic.waRequestURL
        //-->
        let qualityOfServiceClass = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            print("Background API Call about to be called: \(requestName)")
            
            self.loadRequest(self.requestWithURl(Constants.Generic.waRequestURL), Params: postRequestBody, Success: { (data) in
                success(responseData: data as! Dictionary<String, AnyObject>)
            }) { (error) in
                //print(error)
                failure(error: error)
            }
            //dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //    print("This is run on the main queue, after the previous code in outer block")
            //})
        })
        //--<
//        self.loadRequest(requestWithURl(Constants.Generic.waRequestURL), Params: postRequestBody, Success: { (data) in
//            success(responseData: data as! Dictionary<String, AnyObject>)
//        }) { (error) in
//            //print(error)
//            failure(error: error)
//        }
        
        
    }
    
    func requestWithURl(urlString : String) -> NSMutableURLRequest {
        let request = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
