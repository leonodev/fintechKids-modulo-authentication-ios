import Foundation
import SwiftUI

public struct EmailValidator {
    
    // MARK: - Nested Types
    public struct ValidationResult: Sendable {
        public let isValid: Bool
        public let errorType: ValidationError?
        public let message: String
        public let suggestion: String
        
        public init(isValid: Bool, errorType: ValidationError? = nil) {
            self.isValid = isValid
            self.errorType = errorType
            
            if isValid {
                self.message = NSLocalizedString("EMAIL_VALIDATION_VALID", bundle: .module, comment: "")
                self.suggestion = ""
            } else {
                self.message = errorType?.localizedMessage ?? NSLocalizedString("EMAIL_VALIDATION_INVALID_FORMAT", bundle: .module, comment: "")
                self.suggestion = errorType?.recoverySuggestion ?? ""
            }
        }
    }
    
    public enum ValidationError: Error, Equatable, Sendable {
        case empty
        case invalidFormat
        case tooLong(maxLength: Int)
        case missingAtSymbol
        case missingDomain
        case invalidLocalPart
        case invalidDomain
        case consecutiveDots
        case startingOrEndingWithDot
        
        public var localizedMessage: String {
            switch self {
            case .empty:
                return NSLocalizedString("EMAIL_VALIDATION_EMPTY", bundle: .module, comment: "")
            case .invalidFormat:
                return NSLocalizedString("EMAIL_VALIDATION_INVALID_FORMAT", bundle: .module, comment: "")
            case .tooLong(let maxLength):
                let format = NSLocalizedString("EMAIL_VALIDATION_TOO_LONG", bundle: .module, comment: "")
                return String(format: format, maxLength)
            case .missingAtSymbol:
                return NSLocalizedString("EMAIL_VALIDATION_MISSING_AT", bundle: .module, comment: "")
            case .missingDomain:
                return NSLocalizedString("EMAIL_VALIDATION_MISSING_DOMAIN", bundle: .module, comment: "")
            case .invalidLocalPart:
                return NSLocalizedString("EMAIL_VALIDATION_INVALID_LOCAL_PART", bundle: .module, comment: "")
            case .invalidDomain:
                return NSLocalizedString("EMAIL_VALIDATION_INVALID_DOMAIN", bundle: .module, comment: "")
            case .consecutiveDots:
                return NSLocalizedString("EMAIL_VALIDATION_CONSECUTIVE_DOTS", bundle: .module, comment: "")
            case .startingOrEndingWithDot:
                return NSLocalizedString("EMAIL_VALIDATION_STARTING_ENDING_DOT", bundle: .module, comment: "")
            }
        }
        
        public var recoverySuggestion: String {
            switch self {
            case .empty:
                return NSLocalizedString("EMAIL_SUGGESTION_EMPTY", bundle: .module, comment: "")
            case .invalidFormat:
                return NSLocalizedString("EMAIL_SUGGESTION_INVALID_FORMAT", bundle: .module, comment: "")
            case .tooLong:
                return NSLocalizedString("EMAIL_SUGGESTION_TOO_LONG", bundle: .module, comment: "")
            case .missingAtSymbol:
                return NSLocalizedString("EMAIL_SUGGESTION_MISSING_AT", bundle: .module, comment: "")
            case .missingDomain:
                return NSLocalizedString("EMAIL_SUGGESTION_MISSING_DOMAIN", bundle: .module, comment: "")
            case .invalidLocalPart:
                return NSLocalizedString("EMAIL_SUGGESTION_INVALID_LOCAL_PART", bundle: .module, comment: "")
            case .invalidDomain:
                return NSLocalizedString("EMAIL_SUGGESTION_INVALID_DOMAIN", bundle: .module, comment: "")
            case .consecutiveDots:
                return NSLocalizedString("EMAIL_SUGGESTION_CONSECUTIVE_DOTS", bundle: .module, comment: "")
            case .startingOrEndingWithDot:
                return NSLocalizedString("EMAIL_SUGGESTION_STARTING_ENDING_DOT", bundle: .module, comment: "")
            }
        }
    }
    
    // MARK: - Configuration
    public struct Configuration: Sendable {
        public let maxLength: Int
        public let allowSpecialCharacters: Bool
        public let strictValidation: Bool
        
        public init(maxLength: Int, allowSpecialCharacters: Bool, strictValidation: Bool) {
            self.maxLength = maxLength
            self.allowSpecialCharacters = allowSpecialCharacters
            self.strictValidation = strictValidation
        }
        
        // Para propiedades estáticas, las hacemos constantes explícitas
        public static let `default`: Configuration = {
            Configuration(
                maxLength: 254,
                allowSpecialCharacters: true,
                strictValidation: true
            )
        }()
        
        public static let relaxed: Configuration = {
            Configuration(
                maxLength: 254,
                allowSpecialCharacters: true,
                strictValidation: false
            )
        }()
    }
    
    // MARK: - Properties
    private let configuration: Configuration
    
    // MARK: - Initialization
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    public func validate(_ email: String) -> ValidationResult {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validaciones paso a paso con mensajes específicos
        if trimmedEmail.isEmpty {
            return ValidationResult(
                isValid: false,
                errorType: .empty
            )
        }
        
        if trimmedEmail.count > configuration.maxLength {
            return ValidationResult(
                isValid: false,
                errorType: .tooLong(maxLength: configuration.maxLength)
            )
        }
        
        if !trimmedEmail.contains("@") {
            return ValidationResult(
                isValid: false,
                errorType: .missingAtSymbol
            )
        }
        
        let components = trimmedEmail.components(separatedBy: "@")
        guard components.count == 2 else {
            return ValidationResult(
                isValid: false,
                errorType: .missingDomain
            )
        }
        
        let localPart = components[0]
        let domain = components[1]
        
        if localPart.isEmpty || domain.isEmpty {
            return ValidationResult(
                isValid: false,
                errorType: .missingDomain
            )
        }
        
        // Validaciones específicas de la parte local
        if let localPartError = validateLocalPart(localPart) {
            return ValidationResult(
                isValid: false,
                errorType: localPartError
            )
        }
        
        // Validaciones específicas del dominio
        if let domainError = validateDomain(domain) {
            return ValidationResult(
                isValid: false,
                errorType: domainError
            )
        }
        
        if configuration.strictValidation {
            return performStrictValidation(trimmedEmail)
        } else {
            return ValidationResult(isValid: true)
        }
    }
    
    // MARK: - Private Methods
    private func validateLocalPart(_ localPart: String) -> ValidationError? {
        if localPart.hasPrefix(".") || localPart.hasSuffix(".") {
            return .startingOrEndingWithDot
        }
        
        if localPart.contains("..") {
            return .consecutiveDots
        }
        
        let localPartRegex = configuration.allowSpecialCharacters ?
            "^[A-Z0-9a-z._%+-]+$" : "^[A-Z0-9a-z]+$"
        
        let localPartPredicate = NSPredicate(format: "SELF MATCHES %@", localPartRegex)
        if !localPartPredicate.evaluate(with: localPart) {
            return .invalidLocalPart
        }
        
        return nil
    }
    
    private func validateDomain(_ domain: String) -> ValidationError? {
        if domain.hasPrefix(".") || domain.hasSuffix(".") {
            return .invalidDomain
        }
        
        if domain.contains("..") {
            return .invalidDomain
        }
        
        let domainRegex = "^[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let domainPredicate = NSPredicate(format: "SELF MATCHES %@", domainRegex)
        if !domainPredicate.evaluate(with: domain) {
            return .invalidDomain
        }
        
        return nil
    }
    
    private func performStrictValidation(_ email: String) -> ValidationResult {
        let strictRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", strictRegex)
        
        if emailPredicate.evaluate(with: email) {
            return ValidationResult(isValid: true)
        } else {
            return ValidationResult(
                isValid: false,
                errorType: .invalidFormat
            )
        }
    }
}

// MARK: - Extension para String
public extension String {
    var emailValidation: EmailValidator.ValidationResult {
        let validator = EmailValidator()
        return validator.validate(self)
    }
    
    func emailValidation(with configuration: EmailValidator.Configuration) -> EmailValidator.ValidationResult {
        let validator = EmailValidator(configuration: configuration)
        return validator.validate(self)
    }
    
    var isValidEmail: Bool {
        return emailValidation.isValid
    }
}
