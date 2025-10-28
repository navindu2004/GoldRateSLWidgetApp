import Foundation

// --- Data structure that matches the JSON from MetalpriceAPI ---
struct ApiResponse: Codable {
    let success: Bool
    let rates: Rates
    // We make unit optional in case the API doesn't send it
    let unit: String?
}

// --- THIS IS THE CORRECTED PART ---
// We've added the extra fields the server is sending.
// We make them all optional so our code is robust.
struct Rates: Codable {
    let XAU: Double?
    let LKR: Double?
    let USDLKR: Double? // Added this field
    let USDXAU: Double? // Added this field
}

// --- A clean, simple data structure for our widget to use ---
// This remains the same.
struct GoldRateInfo {
    let price24kPerGram: Double
    let price22kPerGram: Double
    let lastUpdated: Date
}
