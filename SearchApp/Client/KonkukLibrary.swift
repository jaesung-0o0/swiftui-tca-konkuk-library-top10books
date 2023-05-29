//
//  LibraryClient.swift
//  SearchApp
//
//  Created by Jaesung Lee on 2023/05/29.
//

import Satellite
import Foundation
import ComposableArchitecture

struct KonkukLibrary {
    static let satellite = Satellite(host: "library.konkuk.ac.kr")
    
    /// 구현하지 않고 정의만 두는 이유는 테스트를 위함
    var searchTop10Books: @Sendable (_ category: Book.Category) async throws -> [Book]
}

extension KonkukLibrary: DependencyKey {
    static let liveValue: KonkukLibrary = .init(
        searchTop10Books: { category in
            let response: Response<BookListData> = try await KonkukLibrary.satellite.response(
                for: "pyxis-api/1/biblio-type-popular-charged-books",
                httpMethod: .get,
                queryItems: [
                    .init(name: "max", value: "10"),
                    .init(name: "biblioType", value: "1,5,6,9,10,19,25,26,13,14"),
                    .init(name: "classNo", value: "\(category.rawValue)"),
                    .init(name: "fromDateReceived", value: "202302"),
                    .init(name: "toDateReceived", value: "202304"),
                ]
            )
            return response.data.list
        }
    )
}

extension DependencyValues {
    var konkukLibrary: KonkukLibrary {
        get { self[KonkukLibrary.self] }
        set { self[KonkukLibrary.self] = newValue }
    }
}

// MARK: For Tests
extension KonkukLibrary: TestDependencyKey {
    static let previewValue = KonkukLibrary(
        searchTop10Books: { _ in Book.mocks }
    )
    
    static let testValue = KonkukLibrary(
        searchTop10Books: unimplemented("\(Self.self).searchTop10Books")
    )
}

extension Book {
    static let mocks: [Book] = [
        Book(
            id: 2063706,
            titleStatement: "물고기는 존재하지 않는다 :상실, 사랑 그리고 숨어 있는 삶의 질서에 관한 이야기",
            author: "Miller, Lulu",
            publisher: "곰",
            thumbnailUrl: "https://image.aladin.co.kr/product/28465/73/cover/k092835920_1.jpg"
        ),
        Book(
            id: 2051273,
            titleStatement: "불편한 편의점 : 김호연 장편소설",
            author: "김호연",
            publisher: "나무옆의자",
            thumbnailUrl: "https://image.aladin.co.kr/product/26942/84/cover/k582730818_1.jpg"
        ),
        Book(
            id: 2034483,
            titleStatement: "공정하다는 착각 : 능력주의는 모두에게 같은 기회를 제공하는가",
            author: "Sandel, Michael J",
            publisher: "와이즈베리",
            thumbnailUrl: "https://image.aladin.co.kr/product/25470/6/cover/k092633826_2.jpg"
        ),
        Book(
            id: 1968347,
            titleStatement: "구의 증명 :최진영 소설",
            author: "최진영",
            publisher: "은행나무",
            thumbnailUrl: "https://image.aladin.co.kr/product/5527/50/cover/8956608555_1.jpg"
        ),
        Book(
            id: 1988385,
            titleStatement: "우리가 빛의 속도로 갈 수 없다면 : 김초엽 소설집",
            author: "김초엽",
            publisher: "허블",
            thumbnailUrl: "https://image.aladin.co.kr/product/19359/16/cover/s012635525_1.jpg"
        ),
        Book(
            id: 2053080,
            titleStatement: "지구 끝의 온실 :김초엽 장편소설",
            author: "김초엽",
            publisher: "자이언트북스",
            thumbnailUrl: "https://image.aladin.co.kr/product/27692/63/cover/k082733434_1.jpg"
        ),
        Book(
            id: 2109216,
            titleStatement: "(누구나 쉽게) 자료구조와 알고리즘 with 파이썬",
            author: "김현정",
            publisher: "길벗캠퍼스",
            thumbnailUrl: "https://shopping-phinf.pstatic.net/main_3692549/36925498620.20230217105836.jpg"
        ),
        Book(
            id: 2031119,
            titleStatement: "대학물리학.1",
            author: "Serway, Raymond A",
            publisher: "북스힐",
            thumbnailUrl: "https://image.aladin.co.kr/product/18748/11/cover/k022635170_2.jpg"
        ),
        Book(
            id: 2079415,
            titleStatement: "채식주의자 :한강 장편소설",
            author: "한강",
            publisher: "창비",
            thumbnailUrl: "https://image.aladin.co.kr/product/29137/2/cover/8936434594_1.jpg"
        ),
        Book(
            id: 2046114,
            titleStatement: "미드나잇 라이브러리",
            author: "Haig, Matt",
            publisher: "인플루엔셜",
            thumbnailUrl: "https://image.aladin.co.kr/product/26987/37/cover/k962730610_1.jpg"
        ),
    ]
}
