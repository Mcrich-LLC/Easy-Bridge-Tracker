//
//  CustomRestaurantFavoritesHandler.swift
//  Pickt
//
//  Created by Morris Richman on 4/3/23.
//

import Foundation

final class FavoritesModel: ObservableObject {
    static let shared = FavoritesModel()
    @Published var favorites: [String] {
        didSet {
            saveFavorites()
            if !favorites.isEmpty {
                ContentViewModel.shared.filterOptions = [.allBridges, .favorites] + ContentViewModel.shared.sortedBridges.compactMap({ .city($0.key) })
            } else {
                ContentViewModel.shared.filterOptions = [.allBridges] + ContentViewModel.shared.sortedBridges.compactMap({ .city($0.key) })
            }
        }
    }
    let fileName = "Favorites.json"
    init() {
        self.favorites = []
        self.getFavorites()
    }
    
    func toggleFavorite(bridgeLocation: String) {
        if self.favorites.contains(bridgeLocation) {
            if let bridges = self.favorites.firstIndex(where: { $0 == bridgeLocation }) {
                self.favorites.remove(at: bridges)
            }
        } else {
            self.favorites.append(bridgeLocation)
        }
    }
    
    func saveFavorites() {
        do {
            enum throwError: Error {
                case unableToWrite
            }
            let jsonEncoder = JSONEncoder()
            jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
            let preferencesJson = try jsonEncoder.encode(favorites)
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let pathWithFileName = documentDirectory.appendingPathComponent(fileName)
                
                try preferencesJson.write(to: pathWithFileName)
            } else {
                throw throwError.unableToWrite
            }
        } catch {
            print("Unable to write json")
        }
    }
    
    func getFavorites() {
        do {
            enum throwError: Error {
                case fileDoesNotExist
            }
            if let filePath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(fileName) {
                let jsonDecoder = JSONDecoder()
                jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
                let favorites = try jsonDecoder.decode([String].self, from: Data(contentsOf: filePath))
                
                self.favorites = favorites
            } else {
                throw throwError.fileDoesNotExist
            }
        } catch {
            print("\(fileName) doesn't exist")
        }
    }
}
