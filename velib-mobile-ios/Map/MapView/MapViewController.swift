//
//  MapViewController.swift
//  velib-mobile-ios
//
//  Created by Mouna EL AMRI on 13/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import UIKit
import GoogleMaps
import RxSwift
import RxCocoa
class MapViewController: UIViewController {
    // MARK: -Variables
    @IBOutlet weak var mapView: GMSMapView!
    let velibClient = VelibCient()
    var map: GMSMapView?
    var selectedVelib: VelibModel?
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var zoomLevel: Float = 13.0
    var isFromVelibList: Bool = false
    var camera:GMSCameraPosition?
    // MARK: -Rx Variables
    var disposeBag = DisposeBag()
    var velibs: BehaviorRelay<[VelibModel]> = BehaviorRelay(value: [VelibModel]())
    // TODO: manage errors
    var isSuccess: BehaviorRelay<(Bool,String)> = BehaviorRelay(value: (false,""))
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    /// LoadView
    override func loadView() {
        super.loadView()
        // Create a GMSCameraPosition that tells the map to display Nantes City
        initMapView()
        // if the controller is load from list then show only the selected station
        // else show all stations
        if !isFromVelibList {
            addObserverOnVelibs()
            getVelibs()
        } else {
            showSelectedVelibOnMap()
        }
    }
    /// DrawMarker depending on the object attributes
    ///
    /// - Parameter velib: <#velib description#>
    func drawMarker(velib: VelibModel)  {
        let marker = GMSMarker()
        if let lat = velib.position?.lat, let long = velib.position?.lng {
            marker.position = CLLocationCoordinate2DMake(lat,long)
            if isFromVelibList {
                camera = GMSCameraPosition.camera(withLatitude: lat,
                                                  longitude: long,
                                                  zoom: zoomLevel)
            }
        }
        if let status = velib.status {
            marker.icon = GMSMarker.markerImage(with: VelibHelper.sharedInstance.colorFromVelibStatus(status: status))
        }
        marker.userData = velib
        marker.map = mapView
    }
    /// Initisalize GMSmapview.
    func initMapView() {
        // Set up GMSCameraPosition to display Nantes city
        camera = GMSCameraPosition.camera(withLatitude: 47.218371, longitude: -1.553621000000021, zoom: zoomLevel)
        mapView?.camera = camera!
        // Enable location on the device
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = self
        // set map type to hybrid
        mapView?.mapType = .hybrid
    }
    /// show selected object when select row from Velib list.
    func showSelectedVelibOnMap() {
        if isFromVelibList  && selectedVelib != nil {
            drawMarker(velib: selectedVelib!)
        }
    }
    /// Draw all velibs on the map.
    func showVelibsOnMap() {
        let velibList = self.velibs.value
        for velib in velibList {
            drawMarker(velib: velib)
        }
    }
    /// Set up Location Manager settings to allow location.
    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    /// get List of velibs.
    func getVelibs() {
        velibClient.getVelibs(velibs: velibs, isSuccess: isSuccess)
    }
    /// add Observer on velib list
    func addObserverOnVelibs() {
        self.velibs.asObservable().subscribe(onNext: { (velibsReturned) in
            self.showVelibsOnMap()
        }, onError: { (_) in

        }).disposed(by: disposeBag)
    }
}
// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    /// Handle location Updates for the location manager.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        print("Location: \(location)")
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView != nil {
            if mapView.isHidden {
                mapView?.isHidden = false
                mapView?.camera = camera
            } else {
                mapView?.animate(to: camera)
            }
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
// MARK: - GMSMapViewDelegate
extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if let infoView = MarkerView.instanceFromNib() as? MarkerView {
            let velib: VelibModel = marker.userData as! VelibModel
            infoView.setupInfoView(velib: velib)
            return infoView
        } else {
            return nil
        }
    }
}
