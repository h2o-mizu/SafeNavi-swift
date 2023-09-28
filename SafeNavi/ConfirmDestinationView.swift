//
//  ConfirmDestinationView.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/22.
//

import SwiftUI
import MapKit

struct ConfirmDestionationView: View {
    
    @EnvironmentObject var mapData: MapViewModel
    @Binding var selectedPoint: MKPlacemark?
    
    @Binding var confirmDestination: Bool
    @Binding var showNavigation: Bool

    var body: some View {
        VStack(spacing: 10){
            Text(selectedPoint?.name ?? "えらばれた ちてん")
                .font(.headline.bold())
                .padding(.top)
            
            HStack(spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedPoint?.subLocality ?? "ついか じょうほう なし")
                        .font(.title3.bold())
                    
                    Text(selectedPoint?.locality ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all, 10)

            Button {
                mapData.decideDestination(destination: selectedPoint!)
                confirmDestination = false
                showNavigation = true
            } label: {
                Text("もくてきち に せってい")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("whiteText"))
            }
            .buttonStyle(CustomButtonStyle(backgroundColor: Color("navy"), strokeColor: Color.clear))
            
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
        .scrollDisabled(true)
        .presentationDetents([.height(200)])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
    }
}
