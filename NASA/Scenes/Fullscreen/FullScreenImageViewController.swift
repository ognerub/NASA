import UIKit
import TinyConstraints

class FullScreenImageViewController: UIViewController {
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bouncesZoom = true
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let wrapperView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let fullscreenImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()
    
    private lazy var imageViewLandscapeConstraint = fullscreenImageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = fullscreenImageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    private let photo: Photo
    
    private let blurEffect = UIBlurEffect(style: .systemThinMaterial)
    
    private lazy var shareButtonContainer: UIVisualEffectView = {
        let shareButtonBlurEffectView = UIVisualEffectView(effect: blurEffect)
        let vibrancyEffectView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: blurEffect))
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(shareFullscreenImage), for: .primaryActionTriggered)
        shareButtonBlurEffectView.contentView.addSubview(vibrancyEffectView)
        vibrancyEffectView.contentView.addSubview(button)
        button.edgesToSuperview()
        vibrancyEffectView.edgesToSuperview()
        shareButtonBlurEffectView.layer.cornerRadius = 24
        shareButtonBlurEffectView.clipsToBounds = true
        shareButtonBlurEffectView.size(CGSize(width: 48, height: 48))
        return shareButtonBlurEffectView
    }()
    
    @objc private func shareFullscreenImage(_ button: UIButton) {
        guard let image: UIImage = fullscreenImageView.image else { return }
        let scaleImageRatio = 700 / image.size.width
        let item: [Any] = [image.scalePreservingAspectRatio(targetSizeScale: scaleImageRatio)]
        let ac = UIActivityViewController(activityItems: item, applicationActivities: nil)
        present(ac, animated: true)
    }

    
    init(photo: Photo, tag: Int) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
        fullscreenImageView.tag = tag
        fullscreenImageView.image = UIImage()
        downloadImageFor(imageView: fullscreenImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureBehaviour()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Force any ongoing scrolling to stop and prevent the image view jumping during dismiss animation.
        // Which is caused by the scroll animation and dismiss animation running at the same time.
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }
    
    private func downloadImageFor(imageView: UIImageView) {
        guard let url = photo.url.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        else { return }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(),
            options: []
        ) { result in
            switch result {
            case .success(_):
                imageView.contentMode = .scaleAspectFill
            case .failure(_):
                imageView.image = UIImage(systemName: "nosign") ?? UIImage()
            }
            
        }
    }
    
    private func configureUI() {
        view.backgroundColor = .clear
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(wrapperView)
        wrapperView.addSubview(fullscreenImageView)
        
        scrollView.edgesToSuperview()
        
        // The wrapper view will fill up the scroll view, and act as a target for pinch and pan event
        wrapperView.edges(to: scrollView.contentLayoutGuide)
        wrapperView.width(to: scrollView.safeAreaLayoutGuide)
        wrapperView.height(to: scrollView.safeAreaLayoutGuide)
        
        fullscreenImageView.centerInSuperview()
        
        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = fullscreenImageView.intrinsicContentSize.height / fullscreenImageView.intrinsicContentSize.width
        fullscreenImageView.heightToWidth(of: fullscreenImageView, multiplier: aspectRatio)
        
        view.addSubview(shareButtonContainer)
        shareButtonContainer.bottomToSuperview(offset: -32, usingSafeArea: true)
        shareButtonContainer.centerXToSuperview(usingSafeArea: true)
    }
    
    private func configureBehaviour() {
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        // scrollView.maximumZoomScale = 1.0001 // "Hack" to enable bouncy zoom without zooming
        scrollView.maximumZoomScale = 2.0
        
        let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(zoomMaxMin))
        doubleTapGestureRecognizer.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    
    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
    
    @objc private func zoomMaxMin(_ sender: UITapGestureRecognizer) {
        if scrollView.zoomScale == scrollView.maximumZoomScale {
            scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
        } else {
            scrollView.setZoomScale(scrollView.maximumZoomScale, animated: true)
        }
    }
}

// MARK: UIScrollViewDelegate

extension FullScreenImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        fullscreenImageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        // Make sure the zoomed image stays centred
        let currentContentSize = scrollView.contentSize
        let originalContentSize = wrapperView.bounds.size
        let offsetX = max((originalContentSize.width - currentContentSize.width) * 0.5, 0)
        let offsetY = max((originalContentSize.height - currentContentSize.height) * 0.5, 0)
        fullscreenImageView.center = CGPoint(x: currentContentSize.width * 0.5 + offsetX,
                                          y: currentContentSize.height * 0.5 + offsetY)
    }
}
