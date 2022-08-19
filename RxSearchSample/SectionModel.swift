//
//  SectionModel.swift
//  RxSearchSample
//
//  Created by 三浦　一真 on 2022/08/19.
//

import Foundation
import RxDataSources

struct SectionModel{
    var items: [GithubRepository]
}

extension SectionModel: SectionModelType{
    init(original: SectionModel, items: [GithubRepository]) {
        self = original
        self.items = items
    }
}
