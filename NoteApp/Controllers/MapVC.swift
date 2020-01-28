//
//  MapVC.swift
//  NoteApp
//
//  Created by Richa Patel on 2020-01-26.
//  Copyright © 2020 Back benchers. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
class MapVC: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    
    var coordinate : CLLocationCoordinate2D!
    @IBOutlet weak var mapView: MKMapView!
    var locatioManager = CLLocationManager()
    var address = ""
    var takeNoteVC : TakeNoteVC?
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locatioManager.delegate = self
        mapView.delegate = self
        locatioManager.desiredAccuracy = kCLLocationAccuracyBest
        locatioManager.requestWhenInUseAuthorization()
        locatioManager.startUpdatingLocation()
            
        }
 
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            //getting users location
            let userLoaction : CLLocation = locations[0]
            
            let lat = userLoaction.coordinate.latitude
            let long = userLoaction.coordinate.longitude
            
            let latDelta:CLLocationDegrees = 0.05
            let longDelta:CLLocationDegrees = 0.05
            
            let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
            
            let loaction = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let region = MKCoordinateRegion(center: loaction, span: span)
            mapView.setRegion(region, animated: true)
            
            print(userLoaction)


            if let takeNoteVC = takeNoteVC {
                
                let desti = CLLocation(coordinate: CLLocationCoordinate2D(latitude: takeNoteVC.newNote!.lat, longitude: takeNoteVC.newNote!.long), altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: Date())
                
                CLGeocoder().reverseGeocodeLocation(desti) { (placemarks, err) in
                    if !placemarks!.isEmpty{
                        self.navigationItem.title = "\(String(placemarks?.first?.subThoroughfare ?? "   ")), \(String(placemarks?.first?.thoroughfare ?? ""))"
                    }
                }

                annotation.title = address
                annotation.coordinate = desti.coordinate
                mapView.addAnnotation(annotation)

                showDirection(source: userLoaction.coordinate, destination: desti.coordinate, type: .automobile)
            }
        }
        
        func showDirection(source : CLLocationCoordinate2D, destination : CLLocationCoordinate2D,type :MKDirectionsTransportType){
            
            mapView.removeOverlays(mapView.overlays)
       
            if destination != nil{
                 
                 let soucePlaceMark = MKPlacemark(coordinate: source)
                 let destPlaceMark = MKPlacemark(coordinate: destination)
                 
                 let sourceItem = MKMapItem(placemark: soucePlaceMark)
                 let destItem = MKMapItem(placemark: destPlaceMark)
                 
                 let destinationRequest = MKDirections.Request()
                 destinationRequest.source = sourceItem
                 destinationRequest.destination = destItem
                 destinationRequest.transportType = type
                 destinationRequest.requestsAlternateRoutes = true
                 
                 let directions = MKDirections(request: destinationRequest)
                 directions.calculate { (response, error) in
                     guard let response = response else {
                        if error != nil {
                             print("Something is wrong :(")
                         }
                         return
                     }
                     
                    let route = response.routes[0]
                    print(route)
                    self.mapView.addOverlay(route.polyline)
                    self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                     
                 }
            }else{
                print("choose desti")
            }
            
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
         
            if overlay is  MKPolyline{
             
            let render = MKPolylineRenderer(overlay: overlay)
                render.strokeColor = .darkGray
                render.lineWidth = 4.0
                return render
            }
            return MKOverlayRenderer()
        }
}
