//
//  CustomExtensions.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 31/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation
import Toast_Swift

public extension UIView{
    
    // Start Busy icon spinning
    public func startBusySpinner(){
        self.makeToastActivity(.Center)
    }
    
    // Stop Busy icon spinning
    public func stopBusySpinner(){
        dispatch_async(dispatch_get_main_queue(), {
            self.hideToastActivity()
        });
    }
    // Stop Busy icon spinning
    public func showToast(message: String){
        dispatch_async(dispatch_get_main_queue(), {
            self.makeToast(message)
        });
    }
}
