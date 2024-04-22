
import Foundation
import Combine

class LinkSessionRequestResponseSubscriber {
    private var publishers = [AnyCancellable]()
    private let envelopesDispatcher: LinkEnvelopesDispatcher

    var onSessionResponse: ((Response) -> Void)?

    init(envelopesDispatcher: LinkEnvelopesDispatcher) {
        self.envelopesDispatcher = envelopesDispatcher
        setupRequestSubscription()
    }

    func setupRequestSubscription() {
        envelopesDispatcher.responseSubscription(on: SessionRequestProtocolMethod())
            .sink { [unowned self] (payload: ResponseSubscriptionPayload<SessionType.RequestParams, AnyCodable>) in
                Task(priority: .high) {
                    onSessionResponse?(Response(
                        id: payload.id,
                        topic: payload.topic,
                        chainId: payload.request.chainId.absoluteString,
                        result: .response(payload.response)
                    ))
                }
            }.store(in: &publishers)
    }
}
