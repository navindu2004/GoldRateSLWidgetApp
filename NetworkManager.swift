// File: NetworkManager.swift

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}

    private let apiKey = "4a17b9518b132bb8434aaa006e08f819"

    func fetchGoldPrice(completion: @escaping (Result<GoldRateInfo, Error>) -> Void) {
        
        let urlString = "https://api.metalpriceapi.com/v1/latest?api_key=\(apiKey)&base=USD&currencies=XAU,LKR"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data received", code: 1, userInfo: nil)))
                return
            }

            // --- THIS IS THE NEW DEBUGGING LINE ---
            // It converts the raw data into text and prints it to the console.
            print("Server Response: \(String(data: data, encoding: .utf8) ?? "Unable to decode response")")
            // -----------------------------------------

            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                
                guard let goldRateInUSD = apiResponse.rates.XAU,
                      let lkrRateInUSD = apiResponse.rates.LKR else {
                    completion(.failure(NSError(domain: "Missing Rates", code: 2, userInfo: nil)))
                    return
                }
                
                let priceOfOneOunceInUSD = 1 / goldRateInUSD
                let priceOfOneOunceInLKR = priceOfOneOunceInUSD * lkrRateInUSD
                let price24kPerGram = priceOfOneOunceInLKR / 31.1035
                let price22kPerGram = price24kPerGram * (22.0 / 24.0)
                
                let goldRateInfo = GoldRateInfo(
                    price24kPerGram: price24kPerGram,
                    price22kPerGram: price22kPerGram,
                    lastUpdated: Date()
                )
                
                DispatchQueue.main.async {
                    completion(.success(goldRateInfo))
                }
                
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
