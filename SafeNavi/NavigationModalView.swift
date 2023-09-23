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

    var body: some View {
        VStack(alignment: .center){
            Button(action: {
                showNavigation = false
                mapData.reset()
            }, label: {
                if(mapData.userIsNearDestination) {
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
        .presentationDetents([.height(80)])
        .presentationBackground(.regularMaterial)
        .presentationBackgroundInteraction(.enabled(upThrough: .height(80)))
    }
}
