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
    
    private var wayPoints: [MKMapItem] = []
    private var routeSegments: [MKRoute] = []
    
    override init(){
        super.init()
        
        completer.delegate = self
        mapView.delegate = self
    }
    
    //FIXME: asyncのroute追加処理が終わるまで待たないとだめ
//    var expectedTotalTravelTime: TimeInterval {
//        var time: TimeInterval = 0.0;
//        for route in routeSegments {
//            time += route.expectedTravelTime
//        }
//        return time
//    }
    
    var userIsNearDestination: Bool {
        if self.endPoint != nil {
            let region = MKCoordinateRegion(center:  self.endPoint!.coordinate, latitudinalMeters: 50, longitudinalMeters: 50)
            if(self.isMapItemWithinRegion(mapItem: MKMapItem(placemark: MKPlacemark(coordinate: mapView.userLocation.coordinate)), region: region)) {
                return true
            }
            return false
        }
        return false
    }
    
    func reset() {
        selectedPoint = nil
        startPoint = nil
        endPoint = nil
        
        wayPoints.removeAll()
        routeSegments.removeAll()
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        
        focusToUser(span: 200)
    }
    
    func focusToUser(span: Double) {
        let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: span, longitudinalMeters: span)
        self.mapView.setRegion(region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
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
        wayPoints.removeAll()
        
        startPoint = MKPlacemark(coordinate: mapView.userLocation.coordinate)
        endPoint = destination
        
        mapView.addAnnotation(self.startPoint!)
        mapView.addAnnotation(self.endPoint!)
        
        self.mapView.setRegion(regionThatFitsTwoPoints(point1: startPoint!, point2: endPoint!, zoom: 1.3), animated: true)
        
        wayPoints.append(MKMapItem(placemark: startPoint!))
        
        let requestWaypoints = MKLocalSearch.Request()
        requestWaypoints.naturalLanguageQuery = "police station"
        requestWaypoints.region = regionThatFitsTwoPoints(point1: startPoint!, point2: endPoint!, zoom: 1.0)
        
        let searchIntersections = MKLocalSearch(request: requestWaypoints)
        searchIntersections.start { response, error in
            if let error = error {
                print("MKLocalSearch Error:\(error)")
                return
            }
            var point1 = self.startPoint!
            if let mapItems = response?.mapItems {
                for mapItem in mapItems {
                    if(self.isMapItemWithinRegion(mapItem: mapItem, region: self.regionThatFitsTwoPoints(point1: point1, point2: self.endPoint!, zoom: 1.0))){
                        self.wayPoints.append(mapItem)
                        let pointAnnotation = MKPointAnnotation()
                        pointAnnotation.coordinate = mapItem.placemark.coordinate
                        pointAnnotation.title = mapItem.placemark.name
                        self.mapView.addAnnotation(pointAnnotation)
                        
                        point1 = mapItem.placemark
                    }
                }
            }
            self.wayPoints.append(MKMapItem(placemark: destination))
            
            self.mapView.removeOverlays(self.mapView.overlays)
            for num in 0..<(self.wayPoints.count - 1) {
                self.drawDirections(start: self.wayPoints[num], end: self.wayPoints[num + 1])
            }
        }
    }
    
    func drawDirections(start: MKMapItem, end: MKMapItem) {
        let directionRequest = MKDirections.Request()
        directionRequest.transportType = MKDirectionsTransportType.walking
        directionRequest.source = start
        directionRequest.destination = end
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            if let error = error {
                print("MKLocalSearch Error: \(error)")
                return
            }
            for route in response!.routes {
                self.routeSegments.append(route)
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)
            }
        }
    }
    
    func regionThatFitsTwoPoints(point1: MKPlacemark, point2: MKPlacemark, zoom: Double) -> MKCoordinateRegion {
        let minLat = min(point1.coordinate.latitude, point2.coordinate.latitude)
        let maxLat = max(point1.coordinate.latitude, point2.coordinate.latitude)
        let minLon = min(point1.coordinate.longitude, point2.coordinate.longitude)
        let maxLon = max(point1.coordinate.longitude, point2.coordinate.longitude)

        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * zoom, longitudeDelta: (maxLon - minLon) * zoom)
        
        return MKCoordinateRegion(center: center, span: span)
    }
    
    func isMapItemWithinRegion(mapItem: MKMapItem, region: MKCoordinateRegion) -> Bool {
        let itemCoordinate = mapItem.placemark.coordinate

        let minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
        let maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
        let minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        let maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)

        if itemCoordinate.latitude >= minLatitude && itemCoordinate.latitude <= maxLatitude &&
            itemCoordinate.longitude >= minLongitude && itemCoordinate.longitude <= maxLongitude {
            return true
        }
        return false
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 9
        renderer.lineJoin = .round
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
