//
//  RoutesDataSource.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/31/15.
//  Copyright © 2015 Grady Zhuo. All rights reserved.
//

import Foundation
import CoreLocation

class RoutesDataSource {
    private static var __allRoutes : [String: Route] = [:]
    
    static let allRoutes:[Route] = {
        
        guard
            let path = NSBundle.mainBundle().pathForResource("busList", ofType: "json"),
            let data = NSData(contentsOfFile: path),
            let JSON = try? NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments),
            let UUIDString:String = NSBundle.mainBundle().infoDictionary?["BeabusProximityUUID"] as? String,
            let UUID = NSUUID(UUIDString: UUIDString)
        else {
            return []
        }
        
        var routesDict:[String:Route] = [:]
        let routesList:[[String:String]] = JSON as! [[String:String]]
        let routes = routesList.reduce([Route](), combine: { (var routes:[Route], element:[String:String]) -> [Route] in
            
            if let routeID = element["RouteID"], routeName = element["RouteName"], routeQueryCode = CLBeaconMajorValue(element["RouteQueryCode"] ?? "") {
                
                let route = Route(name: routeName, identifier: routeID, proximityUUID: UUID, major: routeQueryCode, minor: 0)
                routes.append(route)
                routesDict[routeID] = route
            }
            
            return routes
        })
        
        RoutesDataSource.__allRoutes = routesDict
        
        return routes
        
    }()
    
    
    class func availableRoutesWithLocation(location: CLLocation, completion: ([Route]) ->Void) {
        let _ = self.allRoutes
        let routeIDs = ["109", "207", "280","284","290","311","505","52", "530", "642", "643", "668", "671", "675", "676", "907", "314"]
        let routes:[Route] = routeIDs.reduce([Route]()) { (var routes:[Route], element) -> [Route] in
            if let route = self.__allRoutes[element] {
                routes.append(route)
            }
            return routes
        }
        
        completion(routes)
        
    }
    
}