//
//  GooglePlaceClient.swift
//  Lunch
//
//  Created by Shan on 8/16/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation

// Final: When you dont want a class to be subclassed and any of the implementation
//      overwritten.
final class GooglePlaceClient: APIClient{
    
    // Here we implement method which interupt with spcific part of GooglePlace API
    
    // 1: Implement two property from APIClient
    
    let configuration: NSURLSessionConfiguration
    // Since session is always created by using "configuration",
    //      rather then create an value in the init method, here
    //      we use a lazy property instead.
    
    // This clousure creates an instance of NSURLSession using the 
    //      value asigned to the confuguration "property" and returns it
    lazy var session: NSURLSession = {
        // Assign an clousure to this variable
        // Class initializer takes an configuration
        return NSURLSession(configuration: self.configuration)
    }()
    
    // To asign the value and return from the clousure to "session" store property
    //      we execute the property immiditelly by adding "()" at the end of the clousure 
    
    
    
}
