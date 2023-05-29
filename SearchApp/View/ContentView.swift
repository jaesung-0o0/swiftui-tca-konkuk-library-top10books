//
//  ContentView.swift
//  SearchApp
//
//  Created by Jaesung Lee on 2023/05/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        BookSearchView(
            store: .init(
                initialState: .init(),
                reducer: { BookSearchReducer() }
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
