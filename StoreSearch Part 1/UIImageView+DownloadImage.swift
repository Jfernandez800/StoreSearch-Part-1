import UIKit

extension UIImageView {
    func loadImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        // 1 - After obtaining a reference to the shared URLSession, you create a download task. This is similar to a data task, but it saves the downloaded file to a temporary location on disk instead of keeping it in memory.
        let downloadTask = session.downloadTask(with: url) {
            [weak self] url, _, error in
            // 2 - Inside the completion handler for the download task, you’re given a URL where you can find the downloaded file — this URL points to a local file rather than an internet address. Of course, you must also check that error is nil before you continue.
            if error == nil, let url = url,
               let data = try? Data(contentsOf: url), //3 - With this local URL you can load the file into a Data object and then create an image from that. It’s possible that constructing the UIImage fails, for example, when what you downloaded was not a valid image but a 404 page or something else unexpected. As you can tell, when dealing with networking code, you need to check for errors every step of the way!
               let image = UIImage(data: data) {
                // 4 - Once you have the image, you can put it into the UIImageView’s image property. Because this is UI code you need to do this on the main thread.
                DispatchQueue.main.async {
                    if let weakSelf = self {
                        weakSelf.image = image
                    }
                }
            }
        }
        // 5 - After creating the download task, you call resume() to start it, and then return the URLSessionDownloadTask object to the caller. Why return it? That gives the app the opportunity to call cancel() on the download task if necessary. You’ll see how that works in a minute.
        downloadTask.resume()
        return downloadTask
    }
}
