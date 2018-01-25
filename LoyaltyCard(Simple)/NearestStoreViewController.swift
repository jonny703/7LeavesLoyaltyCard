//
//  NearestStoreViewController.swift
//  LoyaltyCard(Simple)
//
//  Created by John Nik on 2/10/17.
//
//

import UIKit
import MapKit

class NearestStoreViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set mapview delegate for route draw
        mapView.delegate = self
        
        // get source and destination location from StoreManager
        guard let sourceLocation = StoreManager.userCurrectLocation else { return }
        
        // sort to get the nearest location
        let destinationLocation = StoreManager.storeLocations.sorted(by: { loc, loc2 in
            return loc.distance(from: sourceLocation) < loc2.distance(from: sourceLocation)
        })
        
        for loc in StoreManager.storeLocations {
            debugPrint(loc.distance(from: sourceLocation))
        }
        
        let _ = CLLocation(latitude: 34.001385, longitude: -117.72936).coordinate
        
        let sourcePlacemark = MKPlacemark(coordinate: sourceLocation.coordinate, addressDictionary: nil)
        let destinationPlacemark = MKPlacemark(coordinate: (destinationLocation.first?.coordinate)! , addressDictionary: nil)
        
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        let sourceAnnotation = MKPointAnnotation()
        sourceAnnotation.title = "Current Location"
        
        if let location = sourcePlacemark.location {
            sourceAnnotation.coordinate = location.coordinate
        }
        
        
        let destinationAnnotation = MKPointAnnotation()
        destinationAnnotation.title = "Nearest store"
        
        if let location = destinationPlacemark.location {
            destinationAnnotation.coordinate = location.coordinate
        }
        
        // 6.
        self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
        
        // 7.
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceMapItem
        directionRequest.destination = destinationMapItem
        directionRequest.transportType = .automobile
        
        // Calculate the direction
        let directions = MKDirections(request: directionRequest)
        
        // 8.
        directions.calculate {
            (response, error) -> Void in
            
            guard let response = response else {
                if let error = error {
                    print("Error: \(error)")
                }
                
                return
            }
            
            let route = response.routes[0]
            self.mapView.add((route.polyline), level: MKOverlayLevel.aboveRoads)
            
            let rect = route.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegionForMapRect(rect), animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if !(annotation is MKPointAnnotation) {
            return nil
        }
        
        var annotationView: MKAnnotationView?
        
        if annotation.coordinate.latitude == StoreManager.userCurrectLocation?.coordinate.latitude &&
            annotation.coordinate.longitude == StoreManager.userCurrectLocation?.coordinate.longitude
        {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "user")
            
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "user")
                annotationView!.canShowCallout = true
                annotationView!.image = #imageLiteral(resourceName: "user")
            }
            else {
                annotationView!.annotation = annotation
            }

        } else {
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "store")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "store")
                
                annotationView!.canShowCallout = true
                annotationView!.image = #imageLiteral(resourceName: "annotation")
            }
            else {
                annotationView!.annotation = annotation
            } 
        }

        
        
        return annotationView
        
    }
    
    @IBAction func onClose(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
