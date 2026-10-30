import Foundation

struct USDAFood: Codable {
    let description: String
    let foodNutrients: [Nutrient]?
}

struct Nutrient: Codable {
    let nutrientName: String
    let value: Double
}

class NutritionAPI {
    private let usdaKey = "m8mm6GrfCfNR9jTKNKPczFQPT9FqKwBNM88NQHJK"
    
    func searchFood(query: String) async throws -> [FoodItem] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.nal.usda.gov/fdc/v1/foods/search?query=\(encodedQuery)&api_key=\(usdaKey)&pageSize=5"
        
        guard let url = URL(string: urlString) else { return [] }
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode([String: [USDAFood]].self, from: data)
        
        return (response["foods"] ?? []).map { food in
            let nutrients = food.foodNutrients ?? []
            let cal = nutrients.first { $0.nutrientName.contains("Energy") }?.value ?? 0
            let prot = nutrients.first { $0.nutrientName == "Protein" }?.value ?? 0
            let fat = nutrients.first { $0.nutrientName.contains("Total lipid") }?.value ?? 0
            let carb = nutrients.first { $0.nutrientName.contains("Carbohydrate") }?.value ?? 0
            return FoodItem(name: food.description, calories: cal, protein: prot, fat: fat, carbs: carb)
        }
    }
}
