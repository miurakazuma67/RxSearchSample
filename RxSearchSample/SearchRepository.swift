//
//  SearchRepository.swift
//  RxSearchSample
//
//  Created by 三浦　一真 on 2022/08/17.
//

import Foundation
import RxSwift


final class SearchRepository {

    static let shared = SearchViewModel()
    private init () {}

    func request(searchWord: String, completion: @escaping(Result<[GithubRepository], Error>)->Void) {

        guard let url = URL(string: "https://api.github.com/search/repositories?q=\(searchWord)") else { return }
        let task: URLSessionTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do{
                let repository = try JSONDecoder().decode(Repository.self, from: data)
                let items = repository.items
                completion(.success(items))
            }catch{
                completion(.failure(error))
            }
        }
        task.resume()
    }
}

extension SearchRepository: ReactiveCompatible{}
//Reactive Programmingを行うための拡張
extension Reactive where Base: SearchRepository {
    func request (searchWord:String) -> Observable<[GithubRepository]> {
        return Observable.create { observer in
            SearchRepository.shared.request(searchWord: searchWord) { result in
                switch result {
                case .success(let repository):
                    observer.onNext(repository)
                case .failure(let error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }.share(replay: 1, scope: .whileConnected)
    }
}

struct Repository: Codable{
    let items: [GithubRepository]
}

struct GithubRepository: Codable{
    let fullName: String
    let htmlUrl: URL

    enum CodingKeys: String, CodingKey{
        case fullName = "full_name"
        case htmlUrl = "html_url"
    }
}

