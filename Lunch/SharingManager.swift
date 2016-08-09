//
//  SharingManager.swift
//  Lunch
//
//  Created by shan jiang on 04/08/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation

class SharingManager{
    
    var apiServerKey: String = "AIzaSyC133fhGP0pWWyxsJIcO1p5JeAG6T5OdmY"
    
    static let sharedInstance = SharingManager()
    
    var currentLocation = Location(lat: 0.0, long: 0.0, country: "", address: "")
}

