//
//  RoutesManager.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/22/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation

struct Route : CustomStringConvertible, Equatable {
    let name:String
    let proximityUUID:NSUUID
    
    let identifier:String
    var regionIdentifier:String {
        return self.beaconRegion.identifier
    }
    
    var major:CLBeaconMajorValue = 0
    var minor:CLBeaconMinorValue = 0
    
    var enterAlertBody:String{
        return self.description + "公車到了"
    }
    
    let enterSoundName:String
    let leaveSoundName:String
    
    var leaveAlertBody:String{
        return self.description + "公車離開了"
    }
    
    let description:String
    
    var beacons:[CLBeacon] = []
    
    let beaconRegion:CLBeaconRegion
    
    init(name: String, identifier:String, proximityUUID: NSUUID, soundName: String? = nil, description:String? = nil, major:CLBeaconMajorValue = 0, minor:CLBeaconMinorValue = 0){
        
        self.name = name
        self.proximityUUID = proximityUUID
        self.enterSoundName = soundName ?? "\(name)-enter.aiff"
        self.leaveSoundName = soundName ?? "\(name)-leave.aiff"
        self.identifier = identifier
        self.description = description ?? name
        self.major = major
        self.minor = minor
        
        self.beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: major, minor: minor, identifier: [name, identifier].joinWithSeparator(","))
        self.beaconRegion.notifyEntryStateOnDisplay = true
        
    }

    
}


func ==(lhs:Route, rhs:Route)->Bool{
    return lhs.proximityUUID == rhs.proximityUUID && lhs.major == rhs.major && lhs.minor == rhs.minor
}

func ==(lhs:Route, rhs:String)->Bool{
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


extension CLBeaconRegion {
    
    func route()->Route{
        
        let components = self.identifier.componentsSeparatedByString(",")
        let name = components.first ?? ""
        let identifier = components.last ?? ""
        
        return Route(name: name, identifier: identifier, proximityUUID: self.proximityUUID, major: CLBeaconMajorValue(self.major?.integerValue ?? 0), minor: CLBeaconMinorValue(self.minor?.integerValue ?? 0))
    }
    
}


class RoutesManager : NSObject, CLLocationManagerDelegate{
    
    private static let singleton : RoutesManager = RoutesManager()
    
    
    var registeredRoutes:[Route] = []
//    var registeredBuses:[String:Route] = [:]
    
    class var sharedInstance : RoutesManager {
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
        
        self.reloadDetectedRoutes()
    }
    
    
    func reloadDetectedRoutes(){
        self.registeredRoutes = self.locationManager.monitoredRegions.map { (element:CLRegion) -> Route in
            let region = element as! CLBeaconRegion
            return region.route()
        }
    }
    
    func detectBeaconRegionWithBus(route:Route){
        
        self.locationManager.startMonitoringForRegion(route.beaconRegion)
        self.locationManager.startRangingBeaconsInRegion(route.beaconRegion)
        
        self.reloadDetectedRoutes()
    }
    
    func undetectBeaconRegionWithBus(route:Route){
        
        self.locationManager.stopMonitoringForRegion(route.beaconRegion)
        self.locationManager.stopRangingBeaconsInRegion(route.beaconRegion)
        
        self.reloadDetectedRoutes()
    }
    
    func startRaning(){
        
        self.reloadDetectedRoutes()
        for route in self.registeredRoutes {
            let region = CLBeaconRegion(proximityUUID: route.proximityUUID, major: route.major, identifier: route.identifier)
            self.locationManager.startRangingBeaconsInRegion(region)
        }
    }
    
    //delegate
    
    func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
        //
//        for beacon in beacons {
//            
//            let peripheralData = region.peripheralDataWithMeasuredPower(beacon.rssi)
//            print("beacon:\(beacon.rssi) proximity:\(beacon.proximity.rawValue) peripheralData:\(peripheralData)")
//        }
        
    }
    
    
    func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        guard
            let beaconRegion = region as? CLBeaconRegion
            else{
                return
        }
        
        let route = beaconRegion.route()
        
        let notification = UILocalNotification()
        notification.alertBody = route.enterAlertBody
        notification.soundName = route.enterSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
    }
    
    func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
        
        guard
            let beaconRegion = region as? CLBeaconRegion
            else{
                return
        }
        
        let route = beaconRegion.route()
        
        let notification = UILocalNotification()
        notification.alertBody = route.leaveAlertBody
        notification.soundName = route.leaveSoundName
        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        
    }
    
    
    func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion region: CLRegion) {
        
    }

    
}

