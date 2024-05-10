//
//  MainViewControllerViewModel.swift
//  NASA
//
//  Created by Alexander Ognerubov on 10.05.2024.
//

import Foundation


final class MainViewControllerViewModel: ObservableObject {
    @Published var photosArray: [Photo] = []
}
