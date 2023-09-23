//
//  MapViewModel.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/21.
//

import SwiftUI
import MapKit
import CoreLocation

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate, MKLocalSearchCompleterDelegate, MKMapViewDelegate {
    @Published var mapView = MKMapView()
    @Published var permissionDenied = false
    
    var completer = MKLocalSearchCompleter()
    @Published var searchText = ""
    @Published var searchResults: [MKLocalSearchCompletion] = []
    
    @Published var selectedPoint: MKPlacemark?
    @Published var endPoint: MKPlacemark?
    @Published var startPoint: MKPlacemark?
    
    override init(){
        super.init()
        
        completer.delegate = self
        mapView.delegate = self
    }
    
    func searchAddress() {
        if !searchText.isEmpty {
            if completer.queryFragment != searchText {
                completer.queryFragment = searchText
            }
        } else {
            searchResults.removeAll()
        }
    }
    
    func selectPoint(point: MKLocalSearchCompletion) {
        searchResults.removeAll()
        searchText = ""
        mapView.removeAnnotations(mapView.annotations)
        

        let request = MKLocalSearch.Request(completion: point)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let error = error {
                print("MKLocalSearch Error:\(error)")
                return
            }
            if let mapItem = response?.mapItems.first {
                self.selectedPoint = mapItem.placemark
                
                guard let coordinate  = self.selectedPoint?.location?.coordinate else{return}
                
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.coordinate = coordinate
                pointAnnotation.title = self.selectedPoint?.name
                self.mapView.addAnnotation(pointAnnotation)
                
                let span = MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
            }
        }
    }
    
    func decideDestination(destination: MKPlacemark) {
        self.startPoint = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        self.endPoint = destination
        
        mapView.addAnnotation(self.startPoint!)
        mapView.addAnnotation(self.endPoint!)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: self.startPoint!)
        directionRequest.destination = MKMapItem(placemark: self.endPoint!)
        directionRequest.transportType = MKDirectionsTransportType.walking
        directionRequest.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let error = error {
                print("MKLocalSearch Error:\(error)")
                return
            }
            print(response?.routes.count)
            self.mapView.removeOverlays(self.mapView.overlays)
            for route in response!.routes {
                let rect = self.mapView.mapRectThatFits(route.polyline.boundingMapRect, edgePadding: UIEdgeInsets(top: 100, left: 100, bottom: 100, right: 100))
                self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 9
        return renderer
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
            
        if status == .denied {
            permissionDenied.toggle()
            print("denied")
        } else if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        } else if status == .authorizedWhenInUse {
            manager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else{return}
        
        let span = MKCoordinateSpan(latitudeDelta: 0.025, longitudeDelta: 0.025)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            if !self.searchText.isEmpty {
                self.searchResults = completer.results
            } else {
                self.searchResults = .init()
            }
        }
    }
}
