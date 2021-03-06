//
//  OccupancyStatusView.swift
//  OBAKit
//
//  Created by Aaron Brethorst on 12/13/18.
//  Copyright © 2018 OneBusAway. All rights reserved.
//

import UIKit

@objc(OBAOccupancyStatusView)
public class OccupancyStatusView: UIView {

    private let image: UIImage
    private let imageSize: CGFloat = 12.0

    private lazy var scaledImage: UIImage = image.oba_imageScaled(toFit: CGSize(width: imageSize, height: imageSize))

    @objc public var highlightedBackgroundColor = UIColor.clear
    @objc public var defaultBackgroundColor = UIColor(white: 0.98, alpha: 1.0)

    @objc public init(image: UIImage) {
        self.image = image

        super.init(frame: .zero)

        isAccessibilityElement = true
        accessibilityLabel = Bundle(for: OccupancyStatusView.self).localizedString(forKey: "occupancy_status.accessibility_label", value: nil, table: nil)
        accessibilityTraits = [.staticText]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public var intrinsicContentSize: CGSize {
        return CGSize(width: imageSize * CGFloat(maxSilhouetteCount), height: imageSize)
    }

    override public func draw(_ rect: CGRect) {
        super.draw(rect)

        let background = isHighlighted ? highlightedBackgroundColor : defaultBackgroundColor
        background.set()
        UIRectFill(rect)

        let imageWidth = Int(rect.width / CGFloat(maxSilhouetteCount))

        for i in 0..<silhouetteCount {
            let imageRect = CGRect(x: i * imageWidth, y: 0, width: imageWidth, height: Int(scaledImage.size.height))
            scaledImage.draw(in: imageRect)
        }
    }

    private let maxSilhouetteCount = 3

    private var silhouetteCount: Int {
        switch occupancyStatus {
        case .empty: return 1
        case .manySeatsAvailable: return 1
        case .fewSeatsAvailable: return 1
        case .standingRoomOnly: return 2
        case .crushedStandingRoomOnly: return 3
        case .full: return 3
        default: return 0
        }
    }

    @objc public var occupancyStatus: OBAOccupancyStatus = .unknown {
        didSet {
            isHidden = (occupancyStatus == .unknown)

            accessibilityValue = OBALocalizedStringFromOccupancyStatus(occupancyStatus)
            setNeedsDisplay()
        }
    }

    @objc public var isHighlighted = false {
        didSet {
            setNeedsDisplay()
        }
    }
}
