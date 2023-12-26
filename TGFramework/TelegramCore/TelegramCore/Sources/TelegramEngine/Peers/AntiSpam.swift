import Foundation
import PostboxKit
import SwiftSignalKit
import TelegramApi
import MtProtoKit

func _internal_toggleAntiSpamProtection(account: Account, peerId: PeerId, enabled: Bool) -> Signal<Void, NoError> {
    return account.postbox.transaction { transaction -> Signal<Void, NoError> in
        if let peer = transaction.getPeer(peerId), let inputChannel = apiInputChannel(peer) {
            return account.network.request(Api.functions.channels.toggleAntiSpam(channel: inputChannel, enabled: enabled ? .boolTrue : .boolFalse)) |> `catch` { _ in .complete() } |> map { updates -> Void in
                account.stateManager.addUpdates(updates)
            }
        } else {
            return .complete()
        }
    } |> switchToLatest
}

func _internal_reportAntiSpamFalsePositive(account: Account, peerId: PeerId, messageId: MessageId) -> Signal<Bool, NoError> {
    return account.postbox.transaction { transaction -> Signal<Bool, NoError> in
        if let peer = transaction.getPeer(peerId), let inputChannel = apiInputChannel(peer) {
            return account.network.request(Api.functions.channels.reportAntiSpamFalsePositive(channel: inputChannel, msgId: messageId.id))
            |> map { result -> Bool in
                switch result {
                    case .boolTrue:
                        return true
                    case .boolFalse:
                        return false
                }
            }
            |> `catch` { _ -> Signal<Bool, NoError> in
                return .single(false)
            }
        } else {
            return .complete()
        }
    } |> switchToLatest
}
