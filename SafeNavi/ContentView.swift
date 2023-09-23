//
//  ContentView.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    
    @StateObject var mapData = MapViewModel()
    @State var locationManager = CLLocationManager()
    @State private var showSheet = false
    
    var body: some View {
        ZStack{
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea()
                .statusBar(hidden: false)
                .sheet(isPresented: $showSheet) {
                    ModalView(selectedPoint: $mapData.selectedPoint, showSheet: $showSheet)
                        .environmentObject(mapData)
                }
            
            VStack{
                VStack(spacing: 0){
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        
                        TextField("行き先を検索", text: $mapData.searchText)
                            .autocorrectionDisabled()
                            .onChange(of: mapData.searchText, perform: { value in
                                self.mapData.searchAddress()
                            })
                    }
                    .padding(12)
                    .background(.white.opacity(0.9))
                    .cornerRadius(8)
                    .foregroundColor(.primary)
                    
                    if mapData.searchResults.count != 0 {
                        ScrollView{
                            VStack(spacing: 15){
                                ForEach(mapData.searchResults, id: \.self){result in
                                    HStack{
                                        VStack(alignment: .leading) {
                                            Text(result.title)
                                            Text(result.subtitle)
                                                .foregroundColor(Color.primary.opacity(0.5))
                                        }
                                        Spacer()
                                    }
                                    .onTapGesture{
                                        mapData.selectPoint(point: result)
                                        showSheet = true
                                    }
                                }
                                
                                Divider()
                            }
                            .padding(.horizontal, 20)
                            .padding(.top)
                            .background(.white)
                        }
                    }
                }
                .padding()
                
                Spacer()
                
                VStack{
                    Button(action: {}, label: {
                        Image(systemName: "map")
                            .font(.title2)
                            .padding(10)
                            .background(Color.primary)
                            .clipShape(Circle())
                    })
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding()
            }
        }
        .onAppear(perform: {
            locationManager.delegate = mapData
            locationManager.requestWhenInUseAuthorization()
        })
        .alert(isPresented: $mapData.permissionDenied) {
            Alert(title: Text("Permission Denied"), message:
                Text("「設定」より位置情報の取得を許可してください"),
                dismissButton: .default(
                    Text("設定を開く"),
                    action: {
                            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                )
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
