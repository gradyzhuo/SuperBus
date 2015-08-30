//
//  TakenButton.swift
//  SuperBus
//
//  Created by Grady Zhuo on 8/30/15.
//  Copyright © 2015 Grady Zhuo. All rights reserved.
//

import UIKit

class TakenButton: UIButton {
    let bus:Bus
    
    init(bus:Bus, frame:CGRect = CGRect(x: 0, y: 0, width: 38, height: 38)){
        self.bus = bus
        
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.bus = Bus(name: "", proximityUUID: "")
        super.init(coder: aDecoder)
        
    }
    
    
    
}
