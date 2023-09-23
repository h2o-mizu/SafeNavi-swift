//
//  MapView.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/21.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    
    @EnvironmentObject var mapData: MapViewModel
    
    typealias UIViewType = MKMapView


    func makeUIView(context: Context) -> MKMapView {
        
        let view = mapData.mapView
        view.showsUserLocation = true
        view.mapType = .standard
        
        return view
    }

    func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
    }
}
