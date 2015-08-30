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

struct Bus : CustomStringConvertible, Equatable {
    let name:String
    let proximityUUID:NSUUID
//    let lowProximityUUID:NSUUID
    
    let identifier:String
    
    var major:CLBeaconMajorValue = 1
    var minor:CLBeaconMinorValue = 1
    
    var enterAlertBody:String{
        return self.description + "公車到了"
    }
    
    let enterSoundName:String
    let leaveSoundName:String
    
    var leaveAlertBody:String{
        return self.description + "公車離開了"
    }
    
    let description:String
    
    init(name: String, proximityUUID: NSUUID, soundName: String? = nil, description:String? = nil, major:CLBeaconMajorValue = 1, minor:CLBeaconMinorValue = 1){
        
        self.name = name
        self.proximityUUID = proximityUUID
//        self.lowProximityUUID = lowProximityUUID ?? proximityUUID
        self.enterSoundName = soundName ?? "\(name)-enter.aiff"
        self.leaveSoundName = soundName ?? "\(name)-leave.aiff"
        self.identifier = name
        self.description = description ?? name
        self.major = major
        self.minor = minor
    }
    
    init(name: String, proximityUUID: String, soundName: String? = nil, description:String? = nil, major:CLBeaconMajorValue = 1, minor:CLBeaconMinorValue = 1){
        self = Bus(name: name, proximityUUID: NSUUID(UUIDString: proximityUUID) ?? NSUUID(), soundName: soundName, description: description, major: major, minor: minor)
    }
    
}

func ==(lhs:Bus, rhs:Bus)->Bool{
    return lhs.proximityUUID == rhs.proximityUUID && lhs.major == rhs.major && lhs.minor == rhs.minor
}

func ==(lhs:Bus, rhs:String)->Bool{
    return lhs.identifier == rhs
}

extension CLRegionState : CustomStringConvertible {
    
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
        
//        let UUID = NSUUID(UUIDString: bus.proximityUUID) ?? NSUUID()
        let region = CLBeaconRegion(proximityUUID: bus.proximityUUID, major: bus.major, minor: bus.minor, identifier: bus.identifier)//CLBeaconRegion(proximityUUID: UUID, identifier: bus.identifier)
        region.notifyEntryStateOnDisplay = true
        
        self.locationManager.startMonitoringForRegion(region)
        self.locationManager.startRangingBeaconsInRegion(region)
    }
    
    func undetectBeaconRegionWithBus(bus:Bus){
        
        self.registeredBuses.removeValueForKey(bus.identifier)
        
//        let UUID = NSUUID(UUIDString: bus.proximityUUID) ?? NSUUID()
        let region = CLBeaconRegion(proximityUUID: bus.proximityUUID, major: bus.major, minor: bus.minor, identifier: bus.identifier)//CLBeaconRegion(proximityUUID: UUID, identifier: bus.identifier)
        region.notifyEntryStateOnDisplay = true
        
        self.locationManager.stopMonitoringForRegion(region)
        self.locationManager.stopRangingBeaconsInRegion(region)
    }
    
    //delegate
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        //
        print("beacons:\(beacons)")
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        if let bus = self.registeredBuses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.enterAlertBody
            notification.soundName = bus.enterSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        if let bus = self.registeredBuses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.leaveAlertBody
            notification.soundName = bus.leaveSoundName
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
    }

    
}