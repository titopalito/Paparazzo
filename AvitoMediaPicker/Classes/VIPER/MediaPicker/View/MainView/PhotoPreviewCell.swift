import UIKit

final class PhotoPreviewCell: PhotoCollectionViewCell {
    
    private let progressIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.contentMode = .ScaleAspectFit
        
        progressIndicator.hidesWhenStopped = true
        progressIndicator.color = UIColor(red: 162.0 / 255, green: 162.0 / 255, blue: 162.0 / 255, alpha: 1)
        
        addSubview(progressIndicator)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        progressIndicator.center = bounds.center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        progressIndicator.stopAnimating()
    }
    
    override func adjustImageRequestOptions(inout options: ImageRequestOptions) {
        super.adjustImageRequestOptions(&options)
        
        /*
         Вводим downloadId для того чтобы избежать накладывания колбэков от предыдущего и текущего запросов
         при реюзинге ячейки:
            1) onDownloadStarted 1
            2) ячейка реюзается, при этом происходит отмена предыдущих запроса и скачивания
            3) onDownloadStarted 2
            4) onDownloadFinish 1 (тут нам не нужно прятать прелоудер, так как активна вторая операция download)
            5) onDownloadFinish 2 (а здесь уже нужно)
        */
        var downloadId: Int?
        
        options.onDownloadStart = { [weak self, superOptions = options] imageRequestId in
            superOptions.onDownloadStart?(imageRequestId)
            
            self?.imageDownloadId += 1
            downloadId = self?.imageDownloadId
            
            self?.progressIndicator.startAnimating()
        }
        
        options.onDownloadFinish = { [weak self, superOptions = options] imageRequestId in
            superOptions.onDownloadFinish?(imageRequestId)
            
            if downloadId == self?.imageDownloadId {
                self?.progressIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: - Customizable
    
    func customizeWithItem(item: MediaPickerItem) {
        imageSource = item.image
    }
    
    // MARK: - Private
    
    private var imageDownloadId = 0
}
