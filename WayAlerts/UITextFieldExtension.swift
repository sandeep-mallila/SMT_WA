//
//  UITextFieldExtension.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 03/08/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit

private var kAssociationKeyNextField: UInt8 = 0

extension UITextField {
    var nextField: UITextField? {
        get {
            return objc_getAssociatedObject(self, &kAssociationKeyNextField) as? UITextField
        }
        set(newField) {
            objc_setAssociatedObject(self, &kAssociationKeyNextField, newField, .OBJC_ASSOCIATION_RETAIN)
        }
    }
}