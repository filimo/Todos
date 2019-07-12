//
//  ContentView.swift
//  Todos
//
//  Created by Viktor Kushnerov on 7/12/19.
//  Copyright © 2019 Viktor Kushnerov. All rights reserved.
//

import SwiftUI

struct MainView : View {
    @ObjectBinding var todosViewModel = TodosViewModel()
    
    var body: some View {
        VStack {
            List(todosViewModel.todos) { todo in
                Text(todo.title)
            }
            .presentation($todosViewModel.isError) { () -> Alert in
                Alert(title: Text("Error"), message: Text(todosViewModel.error!.localizedDescription))
            }
        }
        .onAppear {
            self.todosViewModel.load()
        }
    }
}

#if DEBUG
struct MainView_Previews : PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
#endif
