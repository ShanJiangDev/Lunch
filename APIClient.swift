//
//  APIClient.swift
//  Lunch
//
//  Created by shan jiang on 09/08/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//

import Foundation

protocol APIClient{
    // Not modify these variable after they created
    var configuration: NSURLSessionConfiguration { get }
    var session: NSURLSession { get }
}