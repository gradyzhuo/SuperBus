//
//  DriverShowStopsTableViewController.swift
//  
//
//  Created by Grady Zhuo on 8/22/15.
//
//

import UIKit
import Alamofire
import MBProgressHUD


class StopButton : UIButton {
    var stop:Stop!
    
}

struct Stop : Equatable {
    let name:String
    var stop:Bool
    
    init(name:String, stop:Bool = false){
        self.name = name
        self.stop = stop
    }
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
    
}


class DriverShowStopsTableViewController: UITableViewController {

    var currentBus:Bus!
    var stopNamesToStop:[String] = []
    
    var HUD:MBProgressHUD?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let stopNames:[String] = ["中和高中","連城路","連城中正路口","連城錦和路口","台貿一村","連城板南路","連城景平路","泰和街中和廟口","中和派出所","南山高中","雙和里","華泰新城","宜安路","宜安吉立智光商職","中興二村","中興新村","得和路口","永和國小","金銀大廈","福和里","福和路","永福橋頭","自來水博物館(太子學舍)","三軍總醫院","耕莘文教院","台電大樓","臺大臺大綜合體育館","龍安國小(公務人力發展中心)","金華新生路口","信義新生路口","幸安國小","仁愛建國路口(一)","仁愛建國路口(二)","仁愛大安路口","仁愛敦化路口","仁愛安和路口","仁愛國泰醫院","仁愛延吉街口","仁愛光復路口","國父紀念館市政府(市府)","松山高中(基隆路)","基隆路口","饒河街觀光夜市(八德)","松山農會","松山車站","松山橋頭","松山車站(八德)","松山農會","饒河街觀光夜市(八德)","基隆路口二松山高中(基隆路)","市政府(市府)","國父紀念館","仁愛光復路口","仁愛延吉街口","仁愛國泰醫院","仁愛安和路口","仁愛敦化路口","仁愛復興路口","仁愛建國路口","一信義新生路口","金華新生路口","和平新生路口","龍安國小(公務人力發展中心)","臺大綜合體育館","臺大捷運公館站","福和橋","福和國中","永利路","金銀大廈","永和國小","得和路口","中興新村","中興二村","智光商職","宜安吉立","宜安路","華泰新城","雙和里南山高中","中和派出所","中和廟口","泰和街","連城景平路","連城板南路","台貿一村","連城錦和路口","連城中正路口","連城路","中和高中"]
        let stops:[Stop] = stopNames.map{ return Stop(name: $0) }
        var bus311 = Bus(name: "311", proximityUUID: "EEEEEEEE-EEEE-EEEE-EEEE-EEEEEEEEEEEE", stops: stops)
        self.currentBus = bus311
        
        
        self.HUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        self.reloadStopData { () -> Void in
            self.HUD?.hide(true)
        }
        
    }
    
    
    func deleteStop(sender:AnyObject){
        
        let button = sender as! StopButton
        let stop = button.stop
        
        Alamofire.request(.DELETE, "http://52.25.36.29/rest/bus/\(self.currentBus.proximityUUID)/stops", parameters: ["stops":stop.name]).response { (request, response, data, error) -> Void in
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                if let data = data {
                    var error:NSError?
                    let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
                    let stopNames:[String] = (json as? [String]) ?? []
                    self.stopNamesToStop = stopNames
                    
                    self.tableView.reloadData()
                }
                
            })
            
        }
        
    }
    
    func clear(){
        
        self.stopNamesToStop = []
        self.tableView.reloadData()
        
        Alamofire.request(.DELETE, "http://52.25.36.29/rest/bus")
        
    }
    
    func reloadStopData(completion:(()->Void)? = nil){
        let url = NSURL(string: "http://52.25.36.29/rest/bus/\(self.currentBus.proximityUUID)/stops")
        
        let dataTask = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
            
            var error:NSError?
            let json:AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &error)
            let stopNames:[String] = (json as? [String]) ?? []
            self.stopNamesToStop = stopNames
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                completion?()
                self.tableView.reloadData()
                
            })
            
        })
        
        dataTask.resume()
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(NSEC_PER_SEC * 2)), dispatch_get_main_queue(), { () -> Void in
            self.reloadStopData()
        })

    }
    
    
    @IBAction func clearAll(sender:AnyObject){
        self.clear()
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
        if contains(self.stopNamesToStop, stop.name) {
            let button = StopButton(frame: CGRect(x: 0, y: 0, width: 38, height: 38))
            button.stop = stop
            button.setImage(UIImage(named: "stop"), forState: UIControlState.Normal)
            button.addTarget(self, action: "deleteStop:", forControlEvents: UIControlEvents.TouchUpInside)
            cell.accessoryView = button
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
