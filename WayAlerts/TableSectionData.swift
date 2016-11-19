//
//  TableSectionData.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import Foundation

class TableSectionData{    
    var Title: String
    var DisplayItemsBundle: [TableRowItem]
    
     init(Title title: String, ContentsArray contentsArray: [TableRowItem]){
        self.Title = title;
        self.DisplayItemsBundle = contentsArray
    }
}