//
//  MapViewController.swift
//  Lunch
//
//  Created by shan jiang on 27/07/16.
//  Copyright © 2016 Shan Jiang. All rights reserved.
//
import UIKit
import GoogleMaps

class MapViewController: UIViewController {

    override func loadView() {
        let currentLocation = SharingManager.sharedInstance.currentLocation;
        let camera = GMSCameraPosition.cameraWithLatitude(currentLocation.lat, longitude: currentLocation.long, zoom: 12)
        let mapView = GMSMapView.mapWithFrame(.zero, camera: camera)
        let marker = GMSMarker()
        marker.position = camera.target
        marker.snippet = "Hello World"
        marker.appearAnimation = kGMSMarkerAnimationPop
        marker.map = mapView
        
        self.view = mapView
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}