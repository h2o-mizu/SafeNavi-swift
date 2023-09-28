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
                        Text("しゅっぱつする ちてん: ")
                            .bold()
                        
                        HStack(alignment: .center, spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            Text(mapData.startPoint?.name ?? "いまいる ちてん")
                                .font(.title3)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 10)
                    }
                    .padding(.vertical, 10)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("いきたい ちてん: ")
                            .bold()
                        
                        HStack(spacing: 10) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.headline)
                                .foregroundColor(.gray)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(mapData.endPoint?.name ?? "えらばれた ばしょ")
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
                    
                    //FIXME: もし時間あったら所要時間(or到着時刻)表示できると嬉しい〜
                    //                    let duration: Duration = .seconds(mapData.expectedTotalTravelTime)
                    //                    Text("推定所要時間: \(duration.formatted())")
                    //                        .bold()
                }

                Button {
                    status = .navigating
                    mapData.focusToUser(span: 50)
                } label: {
                    Text("あんないを はじめる")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color("whiteText"))
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color("redButton"), strokeColor: Color.clear))
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

                Button {
                    status = .confirming
                    showNavigation = false
                    mapData.reset()
                } label: {
                    if(status == .nearDestination) {
                        Text("あんない を おわる")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("whiteText"))
                    } else {
                        Text("あんない を ちゅうだん")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("whiteText"))
                    }
                }
                .buttonStyle(CustomButtonStyle(backgroundColor: Color("redButton"), strokeColor: Color.clear))
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
