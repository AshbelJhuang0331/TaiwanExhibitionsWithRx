//
//  API.swift
//  TaiwanExhibitions
//
//  Created by Chuan-Jie Jhuang on 2022/3/16.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

protocol APIProtocol {
    func requestAllExhibitions() -> Single<[ExhibitionModel]>
}

class API: APIProtocol {
    
    private let disposeBag = DisposeBag()
    private struct URI {
        static let scheme = "https"
        static let host = "cloud.culture.tw"
        static let path = "/frontsite/trans/SearchShowAction.do"
        static let defaultQuery = ""
    }
    
    private var urlComponents = URLComponents()
    private let session = URLSession.shared
    
    init() {
        self.urlComponents.scheme = URI.scheme
        self.urlComponents.host = URI.host
        self.urlComponents.path = URI.path
    }
    
    func requestAllExhibitions() -> Single<[ExhibitionModel]> {
        .create { [weak self] (single) -> Disposable in
            self?.urlComponents.queryItems = [
                "method": "doFindTypeJ",
                "category": "6"
            ].map{ URLQueryItem(name: $0.key, value: $0.value) }
            let url = self?.urlComponents.url
            let request = URLRequest(url: url!)
            
            self?.session.rx.response(request: request)
                .subscribe(onNext: { (response) in
                    var allExhibitions: [ExhibitionModel] = []
                    do {
                        allExhibitions = try JSONDecoder().decode([ExhibitionModel].self, from: response.data)
                        single(.success(allExhibitions))
                    } catch {
                        single(.failure(error))
                    }
                }, onError: { (error) in
                    single(.failure(error))
                })
                .disposed(by: self!.disposeBag)
            return Disposables.create()
        }
    }
    
}
