//
//  ModalView.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/22.
//

import SwiftUI
import MapKit

struct ModalView: View {
    
    @EnvironmentObject var mapData: MapViewModel
    @Binding var selectedPoint: MKPlacemark?
    
    @Binding var showSheet: Bool

    var body: some View {
        VStack(spacing: 10){
            Text(selectedPoint?.name ?? "選択された地点")
                .font(.title2.bold())
                .padding(.top)
            
            HStack(spacing: 10) {
                Image(systemName: "mappin.circle.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(selectedPoint?.subLocality ?? "追加情報なし")
                        .font(.title3.bold())
                    
                    Text(selectedPoint?.locality ?? "")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.all, 10)
            
            Button(action: {
                mapData.decideDestination(destination: selectedPoint!)
                showSheet = false
            }, label: {
                Text("目的地に設定する")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background{
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(.blue)
                    }
                    .overlay(alignment: .trailing, content: {
                        Image(systemName: "arrow.right")
                            .font(.title3.bold())
                            .padding(.trailing)
                            .foregroundColor(.white)
                    })
            })
            
            Spacer()
        }
        .padding()
        .interactiveDismissDisabled()
        .scrollDisabled(true)
        .presentationDetents([.height(200), .large])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .large))
    }
}
