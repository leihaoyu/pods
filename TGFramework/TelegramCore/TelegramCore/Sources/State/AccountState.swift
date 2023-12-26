import Foundation
import PostboxKit
import TelegramApi


extension UnauthorizedAccountTermsOfService {
    init?(apiTermsOfService: Api.help.TermsOfService) {
        switch apiTermsOfService {
            case let .termsOfService(_, id, text, entities, minAgeConfirm):
                let idData: String
                switch id {
                    case let .dataJSON(data):
                        idData = data
                }
                self.init(id: idData, text: text, entities: messageTextEntitiesFromApiEntities(entities), ageConfirmation: minAgeConfirm)
        }
    }
}

extension SentAuthorizationCodeType {
    init(apiType: Api.auth.SentCodeType) {
        switch apiType {
            case let .sentCodeTypeApp(length):
                self = .otherSession(length: length)
            case let .sentCodeTypeSms(length):
                self = .sms(length: length)
            case let .sentCodeTypeCall(length):
                self = .call(length: length)
            case let .sentCodeTypeFlashCall(pattern):
                self = .flashCall(pattern: pattern)
            case let .sentCodeTypeMissedCall(prefix, length):
                self = .missedCall(numberPrefix: prefix, length: length)
            case let .sentCodeTypeEmailCode(flags, emailPattern, length, nextPhoneLoginDate):
                self = .email(emailPattern: emailPattern, length: length, nextPhoneLoginDate: nextPhoneLoginDate, appleSignInAllowed: (flags & (1 << 0)) != 0, setup: false)
            case let .sentCodeTypeSetUpEmailRequired(flags):
                self = .emailSetupRequired(appleSignInAllowed: (flags & (1 << 0)) != 0)
            case let .sentCodeTypeFragmentSms(url, length):
                self = .fragment(url: url, length: length)
            case let .sentCodeTypeFirebaseSms(_, _, _, pushTimeout, length):
                self = .firebase(pushTimeout: pushTimeout, length: length)
        }
    }
}

extension AuthorizationCodeNextType {
    init(apiType: Api.auth.CodeType) {
        switch apiType {
            case .codeTypeSms:
                self = .sms
            case .codeTypeCall:
                self = .call
            case .codeTypeFlashCall:
                self = .flashCall
            case .codeTypeMissedCall:
                self = .missedCall
            case .codeTypeFragmentSms:
                self = .fragment
        }
    }
}
