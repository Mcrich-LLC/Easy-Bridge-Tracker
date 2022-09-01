//
//  BridgeView.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 8/31/22.
//

import SwiftUI
import URLImage
import MapKit
import SwiftUIMap
import SwiftUIX
import Mcrich23_Toolkit

struct BridgeView: View {
    @State var bridge: Bridge
    @ObservedObject var viewModel: ContentViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            if #available(iOS 15, *) {
                AsyncImage(url: bridge.imageUrl) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .fill(alignment: Alignment.center)
                        .ignoresSafeArea()
                } placeholder: {
                    Color.white
//                    Image(systemName: "photo")
//                        .renderingMode(.original)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .fill(alignment: Alignment.center)
//                        .foregroundColor(.gray)
//                        .ignoresSafeArea()
                }
            } else {
                URLImage(bridge.imageUrl) { image in
                    image
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .fill(alignment: Alignment.center)
                        .ignoresSafeArea()
                }
            }
            VStack {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Circle()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .foregroundColor(Color(.systemBackground))
                            .overlay(Image(systemName: "arrow.backward")
                                .foregroundColor(Color.primary)
                                .font(.title3), alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .clipped()
                            .padding()
                    }
                    Spacer()
                    Button {
                        viewModel.fetchData(repeatFetch: false)
                    } label: {
                        Circle()
                            .frame(width: 40, height: 40)
                            .clipped()
                            .foregroundColor(Color(.systemBackground))
                            .overlay(Image(systemName: "arrow.clockwise")
                                .foregroundColor(Color.primary)
                                .font(.title3), alignment: .center)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .clipped()
                            .padding()
                    }
                }
                .padding(.vertical, 76)
                .padding(.horizontal, 24)
                .foregroundColor(Color.white)
                Spacer()
                VStack(alignment: .leading, spacing: 11) {
                    Text(bridge.name)
                        .font(.system(size: 24, weight: .medium, design: .default))
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .clipped()
                    switch bridge.status {
                    case .up:
                        status
                            .background(Color.red)
                            .cornerRadius(12)
                            .padding(.top, 8)
                    case .down:
                        status
                            .background(Color.green)
                            .cornerRadius(12)
                            .padding(.top, 8)
                    case .maintenance:
                        status
                            .background(Color.yellow)
                            .cornerRadius(12)
                            .padding(.top, 8)
                    case .unknown:
                        status
                            .background(Color.yellow)
                            .cornerRadius(12)
                            .padding(.top, 8)
                    }
                    AnnotationMapView(zoom: .constant(0.2), address: .constant(bridge.address), points: .constant([Annotations(title: bridge.name, subtitle: "", address: bridge.address, glyphImage: .assetImage("bridge-icon"))]))
                        .isUserInteractionEnabled(false)
                        .mask(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .onTapGesture {
                            SwiftUIAlert.show(title: "Open Bridge?", message: "Do you want to open \(bridge.name) in maps?", preferredStyle: .alert, actions: [UIAlertAction(title: "Open", style: .default, handler: { _ in
                                UIApplication.shared.open(bridge.mapsUrl)
                            }), UIAlertAction(title: "Cancel", style: .cancel)])
                        }
                }
                .padding(.horizontal, 24)
                Spacer()
                    .frame(height: 100)
                    .clipped()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
            .navigationBarHidden(true)
        }
    }
    var status: some View {
        Text(bridge.status.rawValue.capitalized)
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 15)
            .foregroundColor(Color.white)
    }
}

struct BridgeView_Previews: PreviewProvider {
    static var previews: some View {
        BridgeView(
            bridge: Bridge(name: "Ballard Bridge",
                           status: .down,
                           imageUrl: URL(string: "https://s3-media0.fl.yelpcdn.com/bphoto/rq2iSswXqRp5Nmp7MIEVJg/o.jpg")!,
                           mapsUrl: URL(string: "https://maps.apple.com/?address=Ballard%20Bridge,%20Seattle,%20WA%20%2098199,%20United%20States&ll=47.657044,-122.376245&q=Ballard%20Bridge&_ext=EiYpoLms1YbTR0AxFkGkn4GYXsA5Ho/SMa3UR0BBNmKBHaeXXsBQBA%3D%3D")!,
                           address: "Ballard Bridge, Seattle, WA 98199, United States",
                           latitude: 47.65704,
                           longitude: -122.37624,
                           bridgeLocation: "Seattle, Wa"), viewModel: ContentViewModel()
        )
    }
}

struct PlacePin: Identifiable {
    let id: String
    let location: CLLocationCoordinate2D
    
    init(id: String = UUID().uuidString, latitude: Double, longitude: Double) {
        self.id = id
        self.location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
