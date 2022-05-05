//
//  ExhibitionsViewModel.swift
//  TaiwanExhibitionsWithRx
//
//  Created by Chuan-Jie Jhuang on 2022/4/25.
//

import Foundation
import RxSwift
import RxRelay

class ExhibitionsViewModel {
    
    let apiService: API
    let triggerAPI: AnyObserver<Void>
    
    var isLoading: Observable<Bool>
    let data: Observable<[ExhibitionModel]>
    let showError: Observable<Error>
        
    private let disposeBag = DisposeBag()
    
    init(apiService: API) {
        self.apiService = apiService
        
        showError = Observable<Error>.empty()
        
        let exhibitionsListRelay = BehaviorRelay<[ExhibitionModel]>(value: [])
        data = exhibitionsListRelay.asObservable()
        
        let indicator = ActivityIndicator()
        isLoading = indicator.asObservable()
        
        let triggerAPISubject = PublishSubject<Void>()
        triggerAPI = triggerAPISubject.asObserver()
        
        triggerAPISubject.subscribe { _ in
            exhibitionsListRelay.accept([])
        }.disposed(by: disposeBag)
        
        let fetchExhibitionsListResult = triggerAPISubject
            .asObservable()
            .flatMapLatest { _ in
                apiService.requestAllExhibitions().trackActivity(indicator)
            }.share()
        
        fetchExhibitionsListResult
            .observe(on: MainScheduler.instance)
            .bind { exhibitions -> Void in
                exhibitionsListRelay.accept(exhibitions)
            }.disposed(by: disposeBag)
    }
}
