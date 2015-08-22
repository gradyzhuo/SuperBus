//
//  AppDelegate.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/21/15.
//  Copyright (c) 2015 Grady Zhuo. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

struct Bus {
    let name:String
    let proximityUUID:String
    
    var identifier:String {
        return self.name
    }
    
    let major:Int = 1
    let minor:Int = 1
    
    var soundName:String{
        return self.name + ".aiff"
    }
    
    var alertBody:String{
        return self.name + "公車到了"
    }
    
}

let buses:[String:Bus] = [
    "241":Bus(name: "241", proximityUUID: "EE188576-DC99-4BB5-97A4-138C9DF7E51D"),
    "795往野人谷":Bus(name: "795往野人谷", proximityUUID: "C26D9218-F004-4D66-9A56-4CCD405E16B6"),
    "790漁港":Bus(name: "790漁港", proximityUUID: "FDA50693-A4E2-4FB1-AFCF-C6EB07647825")
]

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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    let locationManager:CLLocationManager = CLLocationManager()
    
    var window: UIWindow?
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let type = UIUserNotificationType.Alert | UIUserNotificationType.Sound
        let setting = UIUserNotificationSettings(forTypes: type, categories: nil)
        application.registerUserNotificationSettings(setting)
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.delegate = self
        
        
        self.register()
        
        return true
    }

    func register(){
        
        for (key, value) in buses {
            self.createBeaconDetecter(value)
        }
        
//        let notifications = buses.map{ return self.createBeaconDetecter($0) }
//        UIApplication.sharedApplication().scheduledLocalNotifications = notifications
    }
    
    func createBeaconDetecter(bus:Bus){
        
        let UUID = NSUUID(UUIDString: bus.proximityUUID)
        let region = CLBeaconRegion(proximityUUID: UUID, identifier: bus.identifier)
        region.notifyEntryStateOnDisplay = true
        
        self.locationManager.pausesLocationUpdatesAutomatically = false
        self.locationManager.startMonitoringForRegion(region)
        self.locationManager.startRangingBeaconsInRegion(region)
    }
    
    
    func locationManager(manager: CLLocationManager!, didRangeBeacons beacons: [AnyObject]!, inRegion region: CLBeaconRegion!) {
        
        println("beacons.count:\(beacons.count)")
        
    }
    
    
    func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
        println("region:\(region.identifier)")
        
        if let bus = buses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.alertBody
            notification.soundName = bus.soundName
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
    }
    
    func locationManager(manager: CLLocationManager!, didDetermineState state: CLRegionState, forRegion region: CLRegion!) {
        
        if state == .Outside || state == .Unknown {
            return
        }
        
        if let bus = buses[region.identifier] {
            let notification = UILocalNotification()
            notification.alertBody = bus.alertBody
            notification.soundName = bus.soundName
            
            UIApplication.sharedApplication().presentLocalNotificationNow(notification)
        }
        
        
        
    }
    
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        completionHandler()
    }
    
    
    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.NoData)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        self.register()
        
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cityhacker.SuperBus" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("SuperBus", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SuperBus.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

}

