//
//  Location.swift
//  Lunch
//
//  Created by shan jiang on 03/08/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation
import CoreLocation


class Location {
    
    var lat: CLLocationDegrees
    var long: CLLocationDegrees
    var country: String
    var address: String
    
    init(lat:CLLocationDegrees, long:CLLocationDegrees, country:String, address:String){
            
        self.lat = lat
        self.long = long
        self.country = country
        self.address = address
    }
}


