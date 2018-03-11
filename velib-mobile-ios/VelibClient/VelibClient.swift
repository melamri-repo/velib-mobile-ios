//
//  VelibClient.swift
//  velib-mobile-ios
//
//  Created by cluster SIG on 11/03/2018.
//  Copyright © 2018 velib. All rights reserved.
//

import Alamofire
import RxSwift
import RxAlamofire
import RxCocoa

let datasource = "https://api.jcdecaux.com/vls/v1/stations?contract=Nantes&apiKey=0e901b8c5c17841c6549066aebdbb854c62111f8"
class VelibCient {
    let disposeBag = DisposeBag()
    /// Get Boxes from (API call)
    ///
    /// - Parameters:
    ///   - url: String
    ///   - boxes: BehaviorRelay<[MessagingBoxModel]>
    func getVelibs(velibs: BehaviorRelay<[VelibModel]>, isSuccess: BehaviorRelay<(Bool,String)>) {
        RxAlamofire.requestData(.get, datasource).debug().subscribe(onNext: { (response, data) in
            if 200..<300 ~= response.statusCode {
                do {
                    let array = try JSONDecoder().decode([VelibModel].self, from: data)
                    velibs.accept(array)
                    isSuccess.accept((true, ""))
                } catch let error as DecodingError {
                    isSuccess.accept((false, "JsonDecodingError"))
                } catch {
                    isSuccess.accept((false, "TechnicalError"))
                }
            } else {
                isSuccess.accept((false, "HttpResponse"))
            }
        }, onError: { (_) in
            isSuccess.accept((false, "TechnicalError"))
        }).disposed(by: disposeBag)
    }
}
