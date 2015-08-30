//
//  BusListController.swift
//  SuperBus
//
//  Created by TsaihongRay on 8/22/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import CoreLocation

class BusListController: UITableViewController {

    let busList = availableBusesList//["0南", "109", "207", "253", "280", "284", "290", "311", "505", "52", "530", "642", "643", "668", "671", "675", "676", "907", "敦化幹線", "棕11", "綠11"]
    
    var takenBus:[Bus] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()

        self.reloadTakenBuses()
        
    }
    
    
    func reloadTakenBuses(){
        self.takenBus = BusesManager.sharedInstance.locationManager.monitoredRegions.map { (element:CLRegion) -> Bus in
            let region = element as! CLBeaconRegion
            return Bus(name: "", proximityUUID: region.proximityUUID, major: CLBeaconMajorValue(region.major?.integerValue ?? 0), minor: CLBeaconMinorValue(region.minor?.integerValue ?? 0))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createTakenButton(bus:Bus)->TakenButton{
        let button = TakenButton(bus: bus)
        button.setImage(UIImage(named: "take"), forState: UIControlState.Normal)
        button.addTarget(self, action: "deleteBus:", forControlEvents: UIControlEvents.TouchUpInside)
        return button
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete method implementation.
        // Return the number of rows in the section.
        return busList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("busLine", forIndexPath: indexPath) 

        // Configure the cell...
        let bus = busList[indexPath.row]
        cell.textLabel?.text = bus.name
        
        cell.accessoryView = nil
        if self.takenBus.contains(bus){
            cell.accessoryView = self.createTakenButton(bus)
        }
        
        return cell
    }
    

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let bus = busList[indexPath.row]
        BusesManager.sharedInstance.detectBeaconRegionWithBus(bus)
        
        
        let button = self.createTakenButton(bus)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryView = button
        
        self.reloadTakenBuses()
        self.tableView.reloadData()
    }
    
    func deleteBus(sender: AnyObject){
        let button = sender as! TakenButton
        let bus = button.bus
        
        BusesManager.sharedInstance.undetectBeaconRegionWithBus(bus)
        self.reloadTakenBuses()
        self.tableView.reloadData()
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
