//
//  ViewController.swift
//  BikerSimulator
//
//  Created by Andres Moreno on 11/15/18.
//  Copyright © 2018 amd. All rights reserved.
//

import UIKit
import CoreMotion
import GoogleMaps

class ViewController: UIViewController {
    let motionManager = CMMotionManager()
    var timer: Timer!
    var mapView : GMSMapView?
    let marker = GMSMarker()
    var lat = -12.078831
    var lng = -77.079212
    let speed = 69000.0 //more is less
    let sensitivity = 0.69
    let zoom = Float(16.9)
    var bikePrev = CLLocationCoordinate2D()
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
        
        
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoom)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        view = mapView
        
        marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        marker.map = mapView
        
    }
    
    
    
    @objc func update() {
        if let accelerometerData = motionManager.accelerometerData {
            //print(accelerometerData)
            print("---------")
            let x = accelerometerData.acceleration.x  * 10
            let y = accelerometerData.acceleration.y  * 10
            
            if x > sensitivity ||  x < -sensitivity{
                print("x: \(x)")
                print("go right")
                lng += x / speed
            }
            if y > sensitivity || y < -sensitivity{
                print("y: \(y)")
                print("go forward")
                lat += y / speed
            }
            mapView?.animate(to: GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoom))
            /*let orientation = getOrientation(bikePrev, CLLocationCoordinate2D(latitude: lat, longitude: lng))
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(1)
            mapView?.animate(to: GMSCameraPosition.camera(withLatitude: lat, longitude: lng, zoom: zoom, bearing: orientation, viewingAngle: 69))
            CATransaction.commit()
            
            */
            
            marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            let orientation = getOrientation(bikePrev, CLLocationCoordinate2D(latitude: lat, longitude: lng))
            
            marker.rotation = orientation
            bikePrev = CLLocationCoordinate2D(latitude: lat, longitude: lng)
            
        }
    }
    
    func getOrientation(_ prevCoord: CLLocationCoordinate2D, _ nextCoord: CLLocationCoordinate2D) -> Double{
        let lat1 = degreesToRadians(degrees: prevCoord.latitude)
        let lon1 = degreesToRadians(degrees: prevCoord.longitude)
        
        let lat2 = degreesToRadians(degrees: nextCoord.latitude)
        let lon2 = degreesToRadians(degrees: nextCoord.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        let orientation = radiansToDegrees(radians: radiansBearing)
        print("Orientation: \(orientation)")
        return orientation
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * .pi / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / .pi }


}

