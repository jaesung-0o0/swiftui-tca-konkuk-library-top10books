# swiftui-tca-konkuk-library-top10books
건국대학교 중앙도서관의 인기도서 Top10 리스트를 카테고리 별로 검색하는 앱

## 개요

건국대학교 중앙도서관의 인기도서 Top10 리스트를 카테고리 별로 검색해보는 아주 간단한 앱프로젝트. 이 프로젝트는 TCA에서 Dependency를 연습하는 것이 목적이다.

## 네트워크 (무시해도 됨)

직접 만든 API 클라이언트 모듈인 [Satellite](https://github.com/ku-ring/the-satellite) 를 사용해서 네트워크 요청과 응답 디코딩 처리.

### 응답 객체

요청을 보내면 대충 아래와 같이 응답이 온다.

```json
{
  "success": true,
  "code": "success.retrieved",
  "message": "Retrieved.",
  "data": {
    "totalCount": 10,
    "list": [
      {
        "id": 2063706,
        "titleStatement": "물고기는 존재하지 않는다 :상실, 사랑 그리고 숨어 있는 삶의 질서에 관한 이야기",
        "author": "Miller, Lulu",
        "publisher": "곰",
        "thumbnailUrl": "https://image.aladin.co.kr/product/28465/73/cover/k092835920_1.jpg",
        ...
      },
      ...
    }
  }
}
```

이를 아래와 같은 구조로 파싱하고자 한다.

`Response`
L `BookListData`
  L `[Book]`
  
```swift
struct Response<DataType: Decodable>: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: DataType
}
```

```swift
struct BookListData: Decodable {
    let totalCount: Int
    let list: [Book]
}
```

```swift
struct Book: Decodable, Equatable, Identifiable {
    let id: Int
    let titleStatement: String
    let author: String
    let publisher: String
    let thumbnailUrl: String
}
```


## Dependency

reducer에서 아래와 같이 dependency 프로퍼티를 선언하기 위해 다음 작업을 한다.
```swift
@Dependency(\.konkukLibrary) var konkukLibrary
```

1. KonkukLibrary 객체 생성. 이 객체의 역할은 satellite 객체를 통해 도서 검색을 하고 요청을 받아오는 것이다.

```swift
struct KonkukLibrary {
    // API client 역할을 하는 satellite 객체
    static let satellite = Satellite(host: "library.konkuk.ac.kr")
    
    /// 구현하지 않고 정의만 두는 이유는 테스트를 위함
    var searchTop10Books: @Sendable (_ category: Book.Category) async throws -> [Book]
}
```

2. `DependencyKey` 채택.

```swift
extension KonkukLibrary: DependencyKey {
    static let liveValue: KonkukLibrary = .init(
        searchTop10Books: { category in
            // Satellite 에 요청보내고 응답 파싱하는 과정 (자세한 내용은 실제 코드 참고)
            let response: Response<BookListData> = try await KonkukLibrary.satellite.response(
                for: "pyxis-api/1/biblio-type-popular-charged-books",
                httpMethod: .get,
                queryItems: [ ... ]
            )
            return response.data.list
        }
    )
}
```

3. `DependencyValues` 에 프로퍼티 추가.

```swift
extension DependencyValues {
    var konkukLibrary: KonkukLibrary {
        get { self[KonkukLibrary.self] }
        set { self[KonkukLibrary.self] = newValue }
    }
}
```

4. 끝

## Reducer Protocol - State, Action 정의

### state, action 구현
```swift
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
}
```

### reduce(into:action:) 구현

> Note:
> What's `cancelInFlight`? 만약 서로 동일한 ID의 in-flight effect 가 있으면, 새로운 effect를 시작하기 전 이전의 것을 취소할지 말지를 결정짓는 파라미터

> Note:
> effect를 cancellable 한 객체로 바굴 때, 반드시 `cancel(id:)` 에서 사용되는 ID를 제공해야합니다. `cancel(id:)` 는 이 ID를 통해 어떤 in-flight effect가 취소되어야 하는지 판단할 수 있습니다. ID에는 `Hashable` 한 값이면 뭐든 사용가능합니다.


```swift
struct BookSearchReducer: ReducerProtocol {
    // dependency 추가
    @Dependency(\.konkukLibrary) var konkukLibrary
    
    // 중복 요청에 대한 cancel(id:) 을 수행할 수 있도록 하기 위한 cancel ID
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
            // 네트워크 요청
            return .run { [category = state.category] send in
                await send(
                    .booksResponse(
                        TaskResult{ try await konkukLibrary.searchTop10Books(category) }
                    )
                )
            }
            .cancellable(id: CancelID.searchBooks, cancelInFlight: true) // TODO: What's `cancelInFlight`?
        // 결과처리 
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
```
