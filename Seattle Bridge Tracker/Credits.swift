//
//  Credits.swift
//  Easy Bridge Tracker
//
//  Created by Morris Richman on 7/31/23.
//

import Foundation
import SwiftUI
import Mcrich23_Toolkit
import SafariServices

struct Credits: View {
    @Environment(\.presentationMode) var presentationMode
    let localizedCredits = [
        "Created by Mcrich LLC™",
        "Powered by Seattle Department of Transportation",
        "Powered by Twitter"
    ]
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(localizedCredits, id: \.self) { credit in
                        HStack {
                            Text(credit)
                            if credit.lowercased().contains("yelp") {
                                Image("yelp logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 15, height: 15)
                            }
                        }
                    }
                } header: {
                    Text("Credits")
                }
                Section {
                    ForEach(OpenSourceLibrary.openSourceLibraries) { library in
                        if let url = library.licenseUrl {
                            Button {
                                let safari = SFSafariViewController(url: url)
                                if UIDevice.current.userInterfaceIdiom == .phone {
                                    safari.modalPresentationStyle = .fullScreen
                                } else {
                                    safari.modalPresentationStyle = .automatic
                                }
                                Mcrich23_Toolkit.topVC().present(safari, animated: true, completion: nil)
                            } label: {
                                HStack {
                                    Text(library.name)
                                        .foregroundColor(.label)
                                    Spacer()
                                    Image(systemSymbol: .chevronRight)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 8.0, height: 11.6)
                                        .font(.body, weight: .bold)
                                        .foregroundColor(Color(hexadecimal: "BFBFBF"))
                                }
                            }
                            
                        } else {
                            Text(library.name)
                        }
                    }
                } header: {
                    Text("Open Source Libraries")
                }
            }
            .navigationTitle("Easy Bridge Tracker™")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                HStack {
                    Spacer()
                    
                    Button {
                        presentationMode.dismiss()
                    } label: {
                        Image(systemSymbol: .xmarkCircleFill)
                            .font(.system(size: 17))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
}

struct OpenSourceLibrary: Identifiable {
    let id = UUID()
    let name: String
    let licenseUrl: URL?
    
    static let openSourceLibraries: [OpenSourceLibrary] = [
        .init(name: "abseil", licenseUrl: URL(string: "https://raw.githubusercontent.com/abseil/abseil-cpp/master/LICENSE")),
        .init(name: "BoringSSL", licenseUrl: URL(string: "https://raw.githubusercontent.com/firebase/boringssl/master/LICENSE")),
        .init(name: "DeviceKit", licenseUrl: URL(string: "https://raw.githubusercontent.com/devicekit/DeviceKit/master/LICENSE")),
        .init(name: "Firebase", licenseUrl: URL(string: "https://raw.githubusercontent.com/firebase/firebase-ios-sdk/master/LICENSE")),
        .init(name: "GoogleAppMeasurement", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/GoogleAppMeasurement/master/LICENSE")),
        .init(name: "GoogleDataTransport", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/GoogleDataTransport/master/LICENSE")),
        .init(name: "Google Mobile Ads SDK", licenseUrl: URL(string: "https://raw.githubusercontent.com/googleads/swift-package-manager-google-mobile-ads/master/LICENSE")),
        .init(name: "Google User Messaging Platform SDK", licenseUrl: URL(string: "https://raw.githubusercontent.com/googleads/swift-package-manager-google-user-messaging-platform/main/LICENSE")),
        .init(name: "GoogleUtilities", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/googleutilities/main/LICENSE")),
        .init(name: "gRPC", licenseUrl: URL(string: "https://raw.githubusercontent.com/grpc/grpc/master/LICENSE")),
        .init(name: "GTMSessionFetcher", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/gtm-session-fetcher/master/LICENSE")),
        .init(name: "LevelDB", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/leveldb/master/LICENSE")),
        .init(name: "LoaderUI", licenseUrl: nil),
        .init(name: "Nanopb", licenseUrl: URL(string: "https://raw.githubusercontent.com/nanopb/nanopb/master/LICENSE.txt")),
        .init(name: "Promises", licenseUrl: URL(string: "https://raw.githubusercontent.com/google/promises/master/LICENSE")),
        .init(name: "RevenueCat", licenseUrl: URL(string: "https://raw.githubusercontent.com/RevenueCat/purchases-ios/master/LICENSE")),
        .init(name: "SFSafeSymbols", licenseUrl: URL(string: "https://raw.githubusercontent.com/SFSafeSymbols/SFSafeSymbols/stable/LICENSE")),
        .init(name: "StepperView", licenseUrl: URL(string: "https://raw.githubusercontent.com/badrinathvm/StepperView/master/LICENSE")),
        .init(name: "Swift Protobuf", licenseUrl: URL(string: "https://raw.githubusercontent.com/apple/swift-protobuf/main/LICENSE.txt")),
        .init(name: "SwiftUIIntrospect", licenseUrl: URL(string: "https://raw.githubusercontent.com/siteline/SwiftUI-Introspect/master/LICENSE")),
        .init(name: "SwiftUI-Shimmer", licenseUrl: URL(string: "https://raw.githubusercontent.com/markiv/SwiftUI-Shimmer/master/LICENSE")),
        .init(name: "SwiftUIBackports", licenseUrl: URL(string: "https://raw.githubusercontent.com/shaps80/SwiftUIBackports/master/LICENSE.md")),
        .init(name: "SwiftUIMap", licenseUrl: URL(string: "https://raw.githubusercontent.com/Mcrich23/SwiftUIMap/main/LICENSE")),
        .init(name: "SwiftUIX", licenseUrl: URL(string: "https://raw.githubusercontent.com/SwiftUIX/SwiftUIX/master/LICENSE.md")),
        .init(name: "URLImage", licenseUrl: URL(string: "https://raw.githubusercontent.com/dmytro-anokhin/url-image/master/LICENSE")),
        .init(name: "WrappingHStack", licenseUrl: URL(string: "https://raw.githubusercontent.com/dkk/WrappingHStack/master/LICENSE"))
    ]
}
