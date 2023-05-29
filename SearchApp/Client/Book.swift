//
//  Book.swift
//  SearchApp
//
//  Created by Jaesung Lee on 2023/05/29.
//

import Foundation

struct Book: Decodable, Equatable, Identifiable {
    let id: Int
    let titleStatement: String
    let author: String
    let publisher: String
    let thumbnailUrl: String
    
    enum Category: Int, Equatable, CaseIterable {
        case 총류
        case 철학
        case 사회과학
        case 어학
        case 자연과학
        case 응용과학
        case 예술
        case 문학
        case 역사
        case 기타
        
        var name: String {
            switch self {
            case .총류:
                return "총류"
            case .철학:
                return "철학"
            case .사회과학:
                return "사회과학"
            case .어학:
                return "어학"
            case .자연과학:
                return "자연과학"
            case .응용과학:
                return "응용과학"
            case .예술:
                return "예술"
            case .문학:
                return "문학"
            case .역사:
                return "역사"
            case .기타:
                return "기타"
            }
        }
    }
}

struct BookListData: Decodable {
    let totalCount: Int
    let list: [Book]
}

struct Response<DataType: Decodable>: Decodable {
    let success: Bool
    let code: String
    let message: String
    let data: DataType
}
