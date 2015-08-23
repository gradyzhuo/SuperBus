//
//  BusesManager.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/22/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

struct Bus : Printable, Equatable {
    let name:String
    let proximityUUID:String
    let lowProximityUUID:String
    let soundName:String
    let identifier:String
    
    let major:Int = 1
    let minor:Int = 1
    
    var alertBody:String{
        return self.description + "公車到了"
    }
    
    let description:String
    
    init(name: String, proximityUUID: String, lowProximityUUID:String? = nil, soundName: String? = nil, description:String? = nil){
        
        self.name = name
        self.proximityUUID = proximityUUID
        self.lowProximityUUID = lowProximityUUID ?? proximityUUID
        self.soundName = soundName ?? "\(name).aiff"
        self.identifier = name
        self.description = description ?? name
    }
    
}


func ==(lhs:Bus, rhs:Bus)->Bool{
    return lhs.identifier == rhs.identifier
}

func ==(lhs:Bus, rhs:String)->Bool{
    return lhs.identifier == rhs
}

extension CLRegionState : Printable {
    
    public var description:String{
        switch self{
        case .Unknown:
            return "Unknow"
        case .Inside:
            return "Inside"
        case .Outside:
            return "Outside"
        }
    }
}


class BusesManager : NSObject, CLLocationManagerDelegate{
    
    private static let singleton : BusesManager = BusesManager()
    
    var registeredBuses:[String:Bus] = [:]
    
    class var sharedInstance : BusesManager {
        return singleton
    }
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    private override init(){
        super.init()
        self.prepareLocationManager()
    }
    
    func prepareLocationManager(){
        
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined {
            
            //給美佳要求location的權限
            let authorizationDescription = NSBundle.mainBundle().infoDictionary?["NSLocationAlwaysUsageDescription"] as? String
            
            let speech = AVSpeechSynthesizer()
            let utterace = AVSpeechUtterance(string: authorizationDescription ?? "")
            utterace.rate = 0.3
            speech.speakUtterance(utterace)
            
            self.locationManager.requestAlwaysAuthorization()
        }
        
        self.locationManager.delegate = self
        self.locationManager.pausesLocationUpdatesAutomatically = false
    }
    
    
    func detectBeaconRegionWithBus(bus:Bus){
        
        self.registeredBuses[bus.identifier] = bus
        
        let UUID = NSUUID(UUIDString: bus.proximityUUID)
        let region = CLBeaconRegion(proximityUUID: UUID, identifier: bus.identifier)
        region.notifyEntryStateOnDisplay = true
        
        self.locationManager.startMonitoringForRegion(region)
        self.locationManager.startRangingBeaconsInRegion(region)
    }
    
    //delegate
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        //
    }
    
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        
        if let bus = self.registeredBuses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.alertBody
            notification.soundName = bus.soundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
        
        if let bus = self.registeredBuses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.name + "公車離開了"
            notification.soundName = bus.soundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        let speech = AVSpeechSynthesizer()
        let utterace = AVSpeechUtterance(string: "機車勒")
        utterace.rate = 0.3
        speech.speakUtterance(utterace)
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
    }

    
}