//
//  ValidationUtils.swift
//  Sway
//
//  Created by Lawrence Jones on 6/8/2025.
//

import Foundation

// MARK: - Validation Functions

func validateLogin(email: String, password: String) -> String? {
    if !isValidEmail(email) { return "Please enter a valid email." }
    if password.isEmpty { return "Please enter your password." }
    return nil
}

func validateSignup(name: String, email: String, password: String, confirm: String, agree: Bool) -> String? {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Please enter a display name." }
    if !isValidEmail(email) { return "Please enter a valid email." }
    if password.count < 8 { return "Password must be at least 8 characters." }
    if scorePassword(password) < 2 { return "Password is too weak. Try adding numbers and symbols." }
    if password != confirm { return "Passwords do not match." }
    if !agree { return "You need to agree to the Terms and Privacy Policy." }
    return nil
}

func isValidEmail(_ email: String) -> Bool {
    let r = #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#
    return email.range(of: r, options: .regularExpression) != nil
}

func scorePassword(_ pw: String) -> Int {
    var s = 0
    if pw.count >= 8 { s += 1 }
    if pw.count >= 12 { s += 1 }
    if pw.rangeOfCharacter(from: .uppercaseLetters) != nil &&
       pw.rangeOfCharacter(from: .lowercaseLetters) != nil { s += 1 }
    if pw.rangeOfCharacter(from: .decimalDigits) != nil { s += 1 }
    if pw.range(of: #"[^A-Za-z0-9]"#, options: .regularExpression) != nil { s += 1 }
    return min(4, s - 1)
}

// MARK: - Fake API Response

struct FakeResponse { 
    let ok: Bool
    let error: String? 
}

func fakeFetch(_ url: String, _ body: [String: Any]) async -> FakeResponse {
    try? await Task.sleep(nanoseconds: 900_000_000)
    return FakeResponse(ok: true, error: nil)
}