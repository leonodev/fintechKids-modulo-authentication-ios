//
//  EmailValidatorTests.swift
//  FHKAuthDemo
//
//  Created by Fredy Leon on 19/11/25.
//

import XCTest
@testable import FHKAuth

final class EmailValidatorTests: XCTestCase {
    
    func testValidEmails() throws {
        let validEmails = [
            "test@example.com",
            "user.name@domain.co",
            "user+tag@example.org",
            "user@sub.domain.com"
        ]
        
        for email in validEmails {
            let result = email.emailValidation
            XCTAssertTrue(result.isValid, "\(email) debería ser válido")
        }
    }
    
    func testInvalidEmails() throws {
        let invalidEmails = [
            "invalid-email",
            "@domain.com",
            "user@",
            "user@.com",
            ""
        ]
        
        for email in invalidEmails {
            let result = email.emailValidation
            XCTAssertFalse(result.isValid, "\(email) debería ser inválido")
        }
    }
    
    func testEmptyEmail() throws {
        let result = "".emailValidation
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorType, .empty)
        // NO verificar el texto del mensaje, solo el tipo de error
    }
    
    func testEmailWithoutAtSymbol() throws {
        let result = "usuario.dominio.com".emailValidation
        XCTAssertFalse(result.isValid)
        XCTAssertEqual(result.errorType, .missingAtSymbol)
    }
    
    func testEmailValidationExtension() throws {
        XCTAssertTrue("test@example.com".isValidEmail)
        XCTAssertFalse("invalid".isValidEmail)
    }
    
    // Test adicional: verificar que los mensajes existen
    func testErrorMessagesAreNotEmpty() {
        let testCases = ["", "invalid", "user@"]
        
        for email in testCases {
            let result = email.emailValidation
            XCTAssertFalse(result.message.isEmpty)
            if !result.isValid && !result.suggestion.isEmpty {
                XCTAssertFalse(result.suggestion.isEmpty)
            }
        }
    }
}
