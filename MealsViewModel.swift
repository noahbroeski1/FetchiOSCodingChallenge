//
//  MealsViewModel.swift
//  FetchCodingChallenge
//
//  Created by Noah Broeski on 3/1/23.
//

import SwiftUI

class MealsViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    
    func fetchMeals() {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/filter.php?c=Dessert") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error fetching meals: \(error.localizedDescription)")
                return
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(MealsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.meals = response.meals
                }
            } catch let error {
                print("Error decoding meals: \(error.localizedDescription)")
            }
        }.resume()
    }

}
