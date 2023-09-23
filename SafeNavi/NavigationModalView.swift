//
//  NavigationModalView.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/23.
//

import SwiftUI

struct NavigationModalView: View {
    
    @EnvironmentObject var mapData: MapViewModel
    
    @Binding var showNavigation: Bool
    
    enum Status {case confirming, navigating, nearDestination}
    @State var status: Status = Status.confirming


    var body: some View {
        if(status == .confirming) {
            VStack{
                Spacer()
                
                VStack(alignment: .leading){
                    VStack(alignment: .leading, spacing: 5) {
                        Text("出発地点: ")
                            .bold()
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            Text(mapData.startPoint?.name ?? "現在地点")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("目的地点: ")
                            .bold()
                        
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mapData.endPoint?.name ?? "選択された地点")
                                    .font(.title3)
                                
                                Text(mapData.endPoint?.subLocality ?? "")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)
                    
//                    Text("推定所要時間: \(90)")
//                        .bold()
                }
                
                Button(action: {
                    status = .navigating
                    mapData.focusToUser(span: 50)
                }, label: {
                    Text("案内を開始する")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background{
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(.blue)
                        }
                })
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .padding()
            .interactiveDismissDisabled()
            .scrollDisabled(true)
            .presentationDetents([.height(300)])
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .height(300)))
        } else {
            VStack{
                Spacer()
                
                Button(action: {
                    status = .confirming
                    showNavigation = false
                    mapData.reset()
                }, label: {
                    if(status == .nearDestination) {
                        Text("案内を終了する")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.blue)
                            }
                    } else {
                        Text("案内を中断する")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background{
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(.white)
                            }
                    }
                })
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .padding()
            .interactiveDismissDisabled()
            .scrollDisabled(true)
            .presentationDetents([.height(100)])
            .presentationBackground(.regularMaterial)
            .presentationBackgroundInteraction(.enabled(upThrough: .height(100)))
        }
    }
}
