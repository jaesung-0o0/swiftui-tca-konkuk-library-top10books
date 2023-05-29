//
//  BookSearchView.swift
//  SearchApp
//
//  Created by Jaesung Lee on 2023/05/29.
//

import SwiftUI
import ComposableArchitecture

struct BookSearchView: View {
    let store: StoreOf<BookSearchReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(Book.Category.allCases, id: \.self) { category in
                            Button {
                                viewStore.send(.selectCategory(category))
                            } label: {
                                Text(category.name)
                                    .font(.footnote)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(.green)
                                    }
                            }
                            .padding(.leading, 16)
                        }
                    }
                }
                .frame(height: 64)
                
                Button {
                    viewStore.send(.tappedSearchButton)
                } label: {
                    Text("검색하기")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background {
                            RoundedRectangle(cornerRadius: 8)
                                .foregroundColor(.green)
                        }
                }
                .padding(12)
                
                ScrollView(showsIndicators: false) {
                    LazyVStack(alignment: .leading) {
                        ForEach(viewStore.books) { book in
                            HStack(alignment: .top) {
                                AsyncImage(url: URL(string: book.thumbnailUrl)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 90, height: 90)
                                        .clipped()
                                } placeholder: {
                                    Image(systemName: "book")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 90, height: 90)
                                        .clipped()
                                }
                                
                                VStack(alignment: .leading) {
                                    Text(book.titleStatement)
                                        .font(.headline)
                                    
                                    Text(book.author)
                                        .font(.subheadline)
                                    
                                    Text(book.publisher)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
