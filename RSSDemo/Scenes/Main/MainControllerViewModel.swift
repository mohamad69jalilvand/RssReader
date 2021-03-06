//
//  MainVM.swift
//  RSSDemo
//
//  Created by MohammadReza Jalilvand on 1/18/20.
//  Copyright © 2020 MohammadReza Jalilvand. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

protocol MainControllerViewModelType: class {
    var modeSelectedSubject: PublishSubject<FetchTarget> { get }
    var cellSelectedSubject: PublishSubject<RssCellViewModelType> { get }
    var cellViewModelsDriver: Driver<[RssCellViewModel]> { get }
    var bookmarkSelectedSubject: PublishSubject<RssCellViewModelType> { get }
    var cellUpdatedDriver: PublishSubject<RssCellViewModelType> { get }
} 

final class MainControllerViewModel: BaseViewModel, MainControllerViewModelType {
    
    // MARK: - Init and deinit
    init(_ networkservice: NetworkService) {
        super.init()
        service = networkservice
        
        modeSelectedSubject
            .bind(onNext: targetSelected)
            .disposed(by: bag)
         
        
        cellSelectedSubject
            .bind(onNext: cellSelected)
            .disposed(by: bag)
        
        bookmarkSelectedSubject
            .bind(onNext: setBookmarked)
            .disposed(by: bag)
    }
    
    deinit {
        print("\(self) dealloc")
    }
    
    
    // MARK: - Properties
    private var service : NetworkService?
    private let dataSubject = BehaviorSubject<[RssCellViewModel]>(value: [])
    
    var modeSelectedSubject = PublishSubject<FetchTarget>()
    var bookmarkSelectedSubject = PublishSubject<RssCellViewModelType>()
    var cellSelectedSubject = PublishSubject<RssCellViewModelType>()
    var cellUpdatedDriver = PublishSubject<RssCellViewModelType>()
    
    var cellViewModelsDriver: Driver<[RssCellViewModel]> {
        return dataSubject.do(onNext: { viewModel in
            self.isLoading = false
        }).asDriver(onErrorJustReturn: [])
    }
    
    // MARK: - Functions
    func targetSelected(_ target: FetchTarget) {
        isLoading = true
        switch target {
        case .unitedSates:
            service?
                .loadXml(SingleXmlResource<Feed>(action: RssAction.unitedStates))
                .map { $0.rss.channel.items.map(RssCellViewModel.init) }
                .subscribe(dataSubject)
                .disposed(by: bag)
            
        case .unitedKingdom:
            service?
                .loadXml(SingleXmlResource<Feed>(action: RssAction.unitedKingdom))
                .map { $0.rss.channel.items.map(RssCellViewModel.init) }
                .subscribe(dataSubject)
                .disposed(by: bag)
        }
    }
    
    func cellSelected(_ viewModel: RssCellViewModelType){
        
    }
    
    func setBookmarked(_ viewModel: RssCellViewModelType){
        let feed = FeedItem(title: viewModel.title, link: viewModel.link, description: "", pubDate: "", category: [])
        BookmarkDAL.shared.insertBookmark(feed: feed){
            
            cellUpdatedDriver.onNext(<#T##element: RssCellViewModelType##RssCellViewModelType#>)
            Notifire.shared().showMessage(message: Message.bookmarkSavedSuccessfully.rawValue, type: .success)
        }
    }
    
    
}
