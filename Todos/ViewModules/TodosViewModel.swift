//
//  TodosViewModel.swift
//  test-SwiftUI-3
//
//  Created by Viktor Kushnerov on 7/10/19.
//  Copyright © 2019 Viktor Kushnerov. All rights reserved.
//

import SwiftUI
import Combine

public class TodosViewModel: BindableObject {
    public let didChange = PassthroughSubject<TodosViewModel, Never>()
    private let errorSubject = PassthroughSubject<APIError, Never>()
    
    public var error: APIError? { didSet { didChange.send(self) } }
    public var isError: Bool {
        get { error != nil }
        set { }
    }
    public var todos = TodosModel() { didSet { didChange.send(self) } }
    
    public var requestCancellable: Cancellable?
    
    deinit {
        requestCancellable?.cancel()
    }
    
    func load() {
        let apiService = APIService("https://jsonplaceholder.typicode.com/todos/")
        
        requestCancellable = apiService
            .fetch()
            .catch { err -> Publishers.Empty<TodosModel, Never> in
                self.errorSubject.send(err)
                return .init()
            }
            .receive(on: RunLoop.main)
            .assign(to: \.todos, on: self)

        _ = errorSubject
            .eraseToAnyPublisher()
            .map { error in error }
            .receive(on: RunLoop.main)
            .assign(to: \.error, on: self)
    }
}
