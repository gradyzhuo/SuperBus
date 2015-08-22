//
//  DriverShowStopsTableViewController.swift
//  
//
//  Created by Grady Zhuo on 8/22/15.
//
//

import UIKit
import Alamofire

struct Stop : Equatable {
    let name:String
    var stop:Bool = false
}

func ==(lhs: Stop, rhs: Stop)->Bool{
    return lhs.name == rhs.name
}

struct Bus : Printable {
    let name:String
    let proximityUUID:String
    let lowProximityUUID:String
    let soundName:String
    let identifier:String
    
    let major:Int = 1
    let minor:Int = 1
    
    
    var stops:[Stop] = []
    
    var alertBody:String{
        return self.description + "公車到了"
    }
    
    let description:String
    
    init(name: String, proximityUUID: String, lowProximityUUID:String? = nil, soundName: String? = nil, description:String? = nil, stops:[Stop] = []){
        
        self.name = name
        self.proximityUUID = proximityUUID
        self.lowProximityUUID = lowProximityUUID ?? proximityUUID
        self.soundName = soundName ?? "\(name).aiff"
        self.identifier = name
        self.description = description ?? name
        self.stops = stops
        
    }
    
    
    mutating func updateStops(stops:[Stop]){
        self.stops = stops
    }
    
}


class DriverShowStopsTableViewController: UITableViewController {

    var currentBus:Bus!
    var stopsToStop:[Stop] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stopNames:[String] = ["中和高中", "連城路", "台貿一村"]
        let stops:[Stop] = stopNames.map{ return Stop(name: $0, stop: true) }
        var bus311 = Bus(name: "311", proximityUUID: "EE188576-DC99-4BB5-97A4-138C9DF7E51D", stops: stops)
        self.currentBus = bus311
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
//        Alamofire.request(.POST, "http://www.google.com", parameters: ["UUID":currentBus.proximityUUID], encoding: ParameterEncoding.PropertyList(NSPropertyListFormat.BinaryFormat_v1_0, 0), headers: nil).responseJSON(options: NSJSONReadingOptions.MutableLeaves) {[unowned self] (request, response, json, error) -> Void in
//            
//            let stopNames:[String] = json as! [String]
//            self.stops = stopNames.map{ return Stop(name: $0, bus: currentBus) }
//            
//            dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0), { () -> Void in
//                self.tableView.reloadData()
//            })
//            
//        }
        
        self.tableView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        return self.currentBus.stops.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("stop", forIndexPath: indexPath) as! UITableViewCell
        
        // Configure the cell...
        let stop = self.currentBus.stops[indexPath.row]
        cell.textLabel?.text = stop.name
        
        cell.accessoryView = nil
        if stop.stop {
            cell.accessoryView = UIImageView(image: UIImage(named: "stop"))
        }
        
        
        return cell
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
