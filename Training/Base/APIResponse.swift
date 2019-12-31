//
//  APIResponse.swift
//  Training
//
//  Created by ManhLD on 12/30/19.
//  Copyright © 2019 ManhLD. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON




class APIMeetUpService<T: MeetUpResponse> {
    
    var request: APIMeetUpRequest?

    init(request: APIMeetUpRequest) {
        self.request = request
    }

    func excute(completionHandler: @escaping (_ response: T?) -> Void, failed: @escaping (_ error : String?) -> Void) {
        request?.printInfomationRequest()
        Alamofire.request(request!.url,
                          method: request!.method,
                          parameters: request?.parameters,
                          headers: request?.header).validate().responseJSON() { response in
            switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completionHandler(T.init(json: json))
                case .failure( _):
                    failed("\(String(describing: response.result.error))")
                    print("\(String(describing: self.request?.name)) error message: \(String(describing: response.result.error))")
            }
        }
    }
}
