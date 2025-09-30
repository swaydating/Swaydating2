//
//  SwayTests.swift
//  SwayTests
//
//  Created by Lawrence Jones on 6/8/2025.
//

import Testing
@testable import Sway

struct SwayTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testEmailValidation() async throws {
        // Test valid emails
        #expect(isValidEmail("test@example.com") == true)
        #expect(isValidEmail("user.name@domain.co.uk") == true)
        
        // Test invalid emails
        #expect(isValidEmail("invalid-email") == false)
        #expect(isValidEmail("@example.com") == false)
        #expect(isValidEmail("test@") == false)
        #expect(isValidEmail("") == false)
    }
    
    @Test func testPasswordScoring() async throws {
        // Test password strength scoring
        #expect(scorePassword("weak") < 2) // Should be weak
        #expect(scorePassword("StrongPassword123!") >= 3) // Should be strong
        #expect(scorePassword("12345678") >= 1) // Long enough but not strong
    }

}
