//
//  ContentView.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI

struct ContentView: View {
    let fetchData = TwitterFetch()
    @State var tweets: [Tweet] = []
    var body: some View {
        VStack {
            List {
                ForEach(tweets, id: \.self) { tweet in
                    Text(tweet.text)
                }
            }
        }
        .onAppear {
            fetchData.fetchTweet { response in
                switch response {
                case .success(let response):
                    self.tweets = response.data
                case .failure(let error):
                    print("error = \(error)")
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
