//
//  BookSearchReducer.swift
//  SearchApp
//
//  Created by Jaesung Lee on 2023/05/29.
//

import Foundation
import ComposableArchitecture

struct BookSearchReducer: ReducerProtocol {
    struct State: Equatable {
        var books: [Book] = []
        var category: Book.Category = .총류
    }
    
    enum Action {
        case selectCategory(Book.Category)
        case tappedSearchButton
        case booksResponse(TaskResult<[Book]>)
    }
    
    @Dependency(\.konkukLibrary) var konkukLibrary
    
    private enum CancelID {
        case searchBooks
    }
    
    func reduce(into state: inout State, action: Action) -> EffectTask<Action> {
        switch action {
        case .selectCategory(let category):
            state.category = category
            return .none
        case .tappedSearchButton:
            state.books = []
            return .run { [category = state.category] send in
                await send(
                    .booksResponse(
                        TaskResult{ try await konkukLibrary.searchTop10Books(category) }
                    )
                )
            }
            .cancellable(id: CancelID.searchBooks, cancelInFlight: true) // TODO: What's `cancelInFlight`?
        case .booksResponse(.success(let books)):
            state.books = books
            return .none
        case .booksResponse(.failure(let error)):
            state.books = []
            print(error.localizedDescription)
            return .none
        }
    }
}
