import Foundation

private var globalTaskIdentifier: Int = 200000

final class SessionDownloadTask: URLSessionDownloadTask {

    // MARK: - Types

    typealias Completion = (URL?, Foundation.URLResponse?, NSError?) -> Void

    // MARK: - Properties

    weak var session: Session!
    let request: URLRequest
    let completion: Completion?

    var _taskIdentifier: Int = {
      globalTaskIdentifier += 1
      return globalTaskIdentifier
    }()
    override var taskIdentifier: Int {
      return _taskIdentifier
    }

    var _originalRequest: URLRequest?
    override var originalRequest: URLRequest? {
      return _originalRequest
    }

    // MARK: - Initializers

    init(session: Session, request: URLRequest, completion: Completion? = nil) {
        self.session = session
        self.request = request
        self.completion = completion
    }

    // MARK: - URLSessionTask

    override func cancel() {
        // Don't do anything
    }

    override func resume() {
        let task = SessionDataTask(session: session, request: request) { data, response, error in
            let location: URL?
            if let data = data {
                // Write data to temporary file
                let tempURL = URL(fileURLWithPath: (NSTemporaryDirectory() as NSString).appendingPathComponent(UUID().uuidString))
                try? data.write(to: tempURL, options: [.atomic])
                location = tempURL
            } else {
                location = nil
            }

            self.completion?(location, response, error)
        }
        task.resume()
    }
}
