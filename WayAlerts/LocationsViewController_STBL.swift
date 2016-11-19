//
//  LocationsViewControl.swift
//  WayAlerts
//
//  Created by SMTIOSDEV01 on 22/07/16.
//  Copyright © 2016 Cognizant. All rights reserved.
//

import UIKit
import CoreData

class LocationsViewControl: UIViewController, UITableViewDataSource, UITableViewDelegate {
 
    @IBOutlet weak var locationsTableView: UITableView!
    //let LocAPI = LocationsAPI.sharedInstance
    
    var appDelegate: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var moc: NSManagedObjectContext = NSManagedObjectContext()
    //var LocAPI: LocationsAPI = LocationsAPI(appDelegate: nil, ManagedObjectContext: nil)
    
    var tableContentsArray = [TableSectionData]()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableContentsArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableContentsArray[section].Title
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let aCell = locationsTableView.dequeueReusableCellWithIdentifier("LocationsCell")!
        
        aCell.textLabel?.text = tableContentsArray[indexPath.section].DisplayItemsBundle[indexPath.row].LabelText
        aCell.detailTextLabel?.text = tableContentsArray[indexPath.section].DisplayItemsBundle[indexPath.row].DetailLabelText
        
        return aCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContentsArray[section].DisplayItemsBundle.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set Core Data properties
        self.appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        self.moc = appDelegate.managedObjectContext
        //var locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        //locationsAPI = LocationsAPI(ApplicationDlegate: self.appDelegate)
        
//        // Get all location requests from local db
//        let locRequestsArray = LocAPI.getLocationsWithAcceptStatus(AcceptStatus: "0")
//        var locReqsSectionContents = [TableRowItem]()
//        
//        // Check to see if no requests avalable, then create an empty one to display a user message
//        let locReqsCount = locRequestsArray.count
//        if ( locReqsCount == 0){
//            let rowItem = TableRowItem()
//            rowItem.LabelText = StringConstants.noLocationRequestsMsg
//            rowItem.DetailLabelText = ""
//            locReqsSectionContents.append(rowItem)
//        }else {
//            // Loop through each of the location and add it to the display tree
//            for aLocRequest in locRequestsArray{
//                let rowItem = TableRowItem()
//                rowItem.LabelText = aLocRequest.name!
//                rowItem.DetailLabelText = aLocRequest.address!
//                locReqsSectionContents.append(rowItem)
//            }
//        }
//        
//        let locReqsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationRequests+" (\(locReqsCount))",ContentsArray: locReqsSectionContents)
//        tableContentsArray.append(locReqsSectionData)
//        
//        // Get all saved locations from local db
//        let locListsArray = LocAPI.getLocationsWithAcceptStatus(AcceptStatus: "1")
//        var locListsSectionContents = [TableRowItem]()
//        
//        let locListsCount = locListsArray.count
//        if ( locListsCount == 0){
//            let rowItem = TableRowItem()
//            rowItem.LabelText = StringConstants.noSavedLocationsMsg
//            rowItem.DetailLabelText = ""
//            locListsSectionContents.append(rowItem)
//        }else {
//            // Loop through each of the location and add it to the display tree
//            for aLocRequest in locListsArray{
//                let rowItem = TableRowItem()
//                rowItem.LabelText = aLocRequest.name!
//                rowItem.DetailLabelText = aLocRequest.address!
//                locListsSectionContents.append(rowItem)
//            }
//        }
//        let locListsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationsList+" (\(locListsCount))",ContentsArray: locListsSectionContents)
//        tableContentsArray.append(locListsSectionData)
        //self.fetchLocationsViewData()

    }
   
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableContentsArray = [TableSectionData]()
        fetchLocationsViewData()
        locationsTableView?.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func fetchLocationRequestsSectionData(){
            // Get all location requests from local db
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
            let locRequestsArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "0")
            var locReqsSectionContents = [TableRowItem]()
            
            // Check to see if no requests avalable, then create an empty one to display a user message
            let locReqsCount = locRequestsArray.count
            if ( locReqsCount == 0){
                let rowItem = TableRowItem()
                rowItem.LabelText = StringConstants.noLocationRequestsMsg
                rowItem.DetailLabelText = ""
                locReqsSectionContents.append(rowItem)
            }else {
                // Loop through each of the location and add it to the display tree
                for aLocRequest in locRequestsArray{
                    let rowItem = TableRowItem()
                    rowItem.LabelText = aLocRequest.name!
                    rowItem.DetailLabelText = aLocRequest.address!
                    locReqsSectionContents.append(rowItem)
                }
            }
            
            let locReqsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationRequests+" (\(locReqsCount))",ContentsArray: locReqsSectionContents)
            tableContentsArray.append(locReqsSectionData)
        }
    
    func fetchLocationsListSectionData(){
        // Get all saved locations from local db
        let locationsAPI = LocationsAPI(ApplicationDelegate: self.appDelegate)
        let locListsArray = locationsAPI.getLocationsWithAcceptStatus(AcceptStatus: "1")
        var locListsSectionContents = [TableRowItem]()
        
        let locListsCount = locListsArray.count
        if ( locListsCount == 0){
            let rowItem = TableRowItem()
            rowItem.LabelText = StringConstants.noSavedLocationsMsg
            rowItem.DetailLabelText = ""
            locListsSectionContents.append(rowItem)
        }else {
            // Loop through each of the location and add it to the display tree
            for aLocRequest in locListsArray{
                let rowItem = TableRowItem()
                rowItem.LabelText = aLocRequest.name!
                rowItem.DetailLabelText = aLocRequest.address!
                locListsSectionContents.append(rowItem)
            }
        }
        let locListsSectionData = TableSectionData(Title: Constants.TableSectionHeaders.LocationsList+" (\(locListsCount))",ContentsArray: locListsSectionContents)
        tableContentsArray.append(locListsSectionData)
    }
    
    func fetchLocationsViewData(){
        self.fetchLocationRequestsSectionData()
        self.fetchLocationsListSectionData()
    }
    
}
