//
//  MapViewController.swift
//  velib-mobile-ios
//
//  Created by Mouna EL AMRI on 13/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit
import GoogleMaps
class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate {
    var mapView: GMSMapView!
    var velib: VelibModel?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 16.0
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    override func loadView() {
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        var camera = GMSCameraPosition.camera(withLatitude: 47.218371, longitude: -1.553621000000021, zoom: zoomLevel)
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        if let lat = self.velib?.position?.lat, let long = self.velib?.position?.lng {
            marker.position = CLLocationCoordinate2DMake(lat,long)
            camera = GMSCameraPosition.camera(withLatitude: lat,
                                                longitude: long,
                                                zoom: zoomLevel)
        }
       // marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
        if let name = self.velib?.name {
            if !name.isEmpty {
                marker.title = name
            }
        }
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        view = mapView
        marker.map = mapView
    }
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    // MARK: - CLLocationManagerDelegate    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
        } else {
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}
