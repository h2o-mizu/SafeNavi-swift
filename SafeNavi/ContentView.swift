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
    
    @State private var confirmDestination = false
    @State private var showNavigation = false
    
    var body: some View {
        ZStack {
            MapView()
                .environmentObject(mapData)
                .ignoresSafeArea()
                .statusBar(hidden: false)
                .sheet(isPresented: $confirmDestination) {
                    ConfirmDestionationView(selectedPoint: $mapData.selectedPoint, confirmDestination: $confirmDestination, showNavigation: $showNavigation)
                        .environmentObject(mapData)
                }
                .sheet(isPresented: $showNavigation) {
                    NavigationModalView(showNavigation: $showNavigation)
                        .environmentObject(mapData)
                }

            VStack {
                if(!showNavigation && !confirmDestination) {
                    SearchBarView(showNavigation: $showNavigation, confirmDestination: $confirmDestination)
                        .environmentObject(mapData)
                }
                
                Spacer()

                Button {
                    mapData.focusToUser(span: 200)
                } label: {
                    Image(systemName: "location.fill")
                        .font(.title2)
                        .padding(15)
                    //FIXME: 青の方がいい？
                        .background(Color("whiteText"))
                        .foregroundColor(Color("navy"))
                        .clipShape(Circle())
                        .shadow(radius: 7)
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
                    //"「設定」より位置情報の取得を許可してください"
                  Text("「せってい」で いちじょうほうの しようを　きょかしてね"),
                  dismissButton: .default(
                    Text("せっていを ひらく"),
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

struct CustomButtonStyle: ButtonStyle {
    var backgroundColor: Color
    var strokeColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
        //TODO: 選択されたらmainカラーにする
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(strokeColor, lineWidth: 1.0)
            )
            .cornerRadius(12)
    }
}
