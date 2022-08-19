//
//  SearchViewModel.swift
//  RxSearchSample
//
//  Created by 三浦　一真 on 2022/08/17.
//

import Foundation
import RxSwift
import RxCocoa
import RxOptional

protocol SearchViewModelInput {
    //Input: searchBar.textに何か入力された
    var searchTextObserver: AnyObserver<String?> { get }
}

protocol SearchViewModelOutput {
    //RxDataSources
    var dataRelay: BehaviorRelay<[SectionModel]> { get }
}

final class SearchViewModel: SearchViewModelInput, SearchViewModelOutput {

    private let disposeBag = DisposeBag()
    private let sectionModel: [SectionModel]!
    /*Input*/
    private let _searchText = PublishRelay<String?>()
    lazy var searchTextObserver: AnyObserver<String?> = .init { [weak self] event in
        guard let element = event.element else { return }
        self?._searchText.accept(element)
    }

    /*Output*/
    lazy var dataRelay = BehaviorRelay<[SectionModel]>(value: [])

    init() {

        sectionModel = [SectionModel(items: [])]

        //dataRelayに初期設定のsectionModelを流す
        Observable.deferred { () -> Observable<[SectionModel]> in
            return Observable.just(self.sectionModel)
        }.bind(to: dataRelay)
        .disposed(by: disposeBag)

        //ここより下は、検索した際に文字入力中にViewとViewModelを繋げる役割
        _searchText
            //0.5秒新たなイベントが発行されなくなってから最後に発行されたイベントを使用する
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            //流れてくる値が前回と違う時のみイベントを流す
            .distinctUntilChanged()
            //アンラップ
            .filterNil()
            .filter{ $0.isNotEmpty }
            .flatMapLatest { searchText in
                SearchRepository.shared.rx.request(searchWord: searchText)
                    .map { repositories -> [SectionModel] in
                        [SectionModel(items: repositories)]
                    }
                //dateRelayに新しいSectionModelを流すと勝手にreloadしてくれる
            }.bind(to: dataRelay)
            .disposed(by: disposeBag)
    }
}
