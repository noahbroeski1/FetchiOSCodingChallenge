import SwiftUI

struct Meal: Codable {
    let id: String
    let name: String
    let category: String
    let instructions: String
    let thumbnailURL: URL
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case category = "strCategory"
        case instructions = "strInstructions"
        case thumbnailURL = "strMealThumb"
    }
}

struct MealList: Codable {
    let meals: [Meal]
}


struct ContentView: View {
    @StateObject var viewModel: MealsViewModel
    
    init() {
        _viewModel = StateObject(wrappedValue: MealsViewModel())
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.meals) { meal in
                NavigationLink(destination: MealDetail(meal: meal)) {
                    MealRow(meal: meal)
                }
            }
            .navigationBarTitle("Desserts")
        }
        .onAppear {
            viewModel.fetchMeals()
        }
    }
}

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

struct MealRow: View {
    let meal: Meal
    
    var body: some View {
        HStack {
            Image(uiImage: UIImage(data: try! Data(contentsOf: meal.thumbnailURL)) ?? UIImage())
                .resizable()
                .frame(width: 60, height: 60)
                .aspectRatio(contentMode: .fit)
            Text(meal.name)
                .font(.headline)
        }
    }
}

struct MealDetail: View {
    let meal: Meal
    
    var body: some View {
        ScrollView {
            Image(uiImage: UIImage(data: try! Data(contentsOf: meal.thumbnailURL)) ?? UIImage())
                .resizable()
                .scaledToFit()
            Text(meal.name)
                .font(.title)
                .padding()
            Text(meal.instructions)
                .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(meal.name)
    }
}

