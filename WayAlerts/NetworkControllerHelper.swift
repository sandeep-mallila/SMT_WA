//
//  DataControllerHelper.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 16/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit

class NetworkControllerHelper: NSObject {
    static let sharedInstance = NetworkControllerHelper()
    
    func  getAPIRequestDict(requestName : String, requestParameters : Dictionary<String,String>) -> Dictionary<String,String> {
        // This function is reesponsible for creating the required request JSON as accepted by the requestName.
        // requestParameters is a dictionary object with keys and values as accepted by the requestParameters section of the API request.
        var requesterID = Utils.getThisUserID();
        
        if(requesterID == ""){
            requesterID = "NA";
        }        
        
        // Loop through each of the requestParmeters and create a JSON string
        var paramsDataString = "{";
        for (key,value) in requestParameters{
            if(paramsDataString == "{"){
                paramsDataString = paramsDataString + "\"\(key)\":\"\(value)\"";
            }else{
                paramsDataString = paramsDataString + "," + "\"\(key)\":\"\(value)\"";
            }
        }
        paramsDataString = paramsDataString + "}";
        
        let returnDict: [String:String] = [
            "requesterid":requesterID,
            "requestname":requestName,
            "requestparameters":paramsDataString
        ];
        return returnDict as Dictionary<String,String>;
    }
}
