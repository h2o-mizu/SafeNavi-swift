//
//  SearchBar.swift
//  SafeNavi
//
//  Created by Arisa Okamura on 2023/09/23.
//

import SwiftUI

struct SearchBarView: View {
    
    @EnvironmentObject var mapData: MapViewModel
    
    @Binding var showNavigation: Bool
    @Binding var confirmDestination: Bool
    
    var body: some View {
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
            .padding(13)
            .background(.white.opacity(0.9))
            .cornerRadius(30)
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
                                confirmDestination = true
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
        .shadow(radius: 10)
    }
}
