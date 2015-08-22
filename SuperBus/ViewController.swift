//
//  ViewController.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/21/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager!
    
    let uuid = NSUUID(UUIDString: "EE188576-DC99-4BB5-97A4-138C9DF7E51D")
    let identifier = "com.mycompany.myregion"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager = CLLocationManager()
        locationManager.delegate = self
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let region = CLBeaconRegion(proximityUUID: uuid, identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        //     region.notifyEntryStateOnDisplay = YES;
        locationManager.startMonitoringForRegion(region)
        locationManager.startRangingBeaconsInRegion(region)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // delegates
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!)
    {
        var controller = UIAlertController(title: "Found beacon", message: "yay", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: {(paramAction:UIAlertAction!) in
            println("OK Tapped")
        })
        controller.addAction(action)
    }
}

