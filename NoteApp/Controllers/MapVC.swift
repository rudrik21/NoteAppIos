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
    var delegate : TakeNoteVC?
    var annotation = MKPointAnnotation()
    
    override func viewDidLoad() {
        super.viewDidLoad()

                locatioManager.delegate = self
                mapView.delegate = self
                locatioManager.desiredAccuracy = kCLLocationAccuracyBest
                locatioManager.requestWhenInUseAuthorization()
                locatioManager.startUpdatingLocation()
        
                var desti = CLLocationCoordinate2D(latitude: delegate?.currentNote?.lat ?? 0.0, longitude: delegate?.currentNote?.long ?? 0.0)
        
            annotation.title = address
            annotation.coordinate = desti
            mapView.addAnnotation(annotation)
        
        showDirection(destination: desti, type: .automobile)
      
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

                
            }
        
        func showDirection(destination : CLLocationCoordinate2D,type :MKDirectionsTransportType){
            
       
            if destination != nil{
                let souceCordinate = mapView.annotations.first!.coordinate
                 
                 let soucePlaceMark = MKPlacemark(coordinate: souceCordinate)
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
                         if let error = error {
                             print("Something is wrong :(")
                         }
                         return
                     }
                     
                   let route = response.routes[0]
                    print(route)
                    self.mapView.addOverlay(route.polyline)
                    print("hi")
                //  self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                     
                 }
            }else{
                print("choose desti")
            }
            
        }
            
        
        @objc func onTap(gestureRecognizer : UIGestureRecognizer){
            
          
            if gestureRecognizer.state == .ended{
              
                     let destination_loaction = gestureRecognizer.location(in: mapView)
                       coordinate = mapView.convert(destination_loaction, toCoordinateFrom: mapView)
                          let annotation = MKPointAnnotation()
                
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
                CLGeocoder().reverseGeocodeLocation(CLLocation(coordinate: coordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, course: 0, speed: 0, timestamp: Date())) { (placemark, error) in
                               
                               if let error = error{
                                   print(error)
                               }else{
                                   
                                   if let placemark = placemark?[0]{
                                      
                                       self.address = ""
                                       if placemark.name != nil{
                                           self.address = placemark.name!
                                       }
                                   }
                               }
                           }

                             annotation.title = address
                             annotation.coordinate = coordinate
                                
                             mapView.addAnnotation(annotation)
           
            
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
