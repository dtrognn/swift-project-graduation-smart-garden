//
//  ProgressBar.swift
//  SmartGadrden
//
//  Created by Vu Duc Trong on 10/04/2023.
//

import UIKit

class ProgressBar: UIView {
    @IBInspectable public lazy var startGradientColor: UIColor = .green
    @IBInspectable public lazy var endGradientColor: UIColor = .blue
    @IBInspectable public lazy var backgroundCircleColor: UIColor = .lightGray
    @IBInspectable public lazy var clearColor: UIColor = .clear

    let progressLayer = CAShapeLayer()
    let backgroundLayer = CAShapeLayer()
    let textLayer = CATextLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }

    private func configure() {
        let startAngle = -CGFloat.pi/2
        let endAngle = 2 * CGFloat.pi + startAngle

        let width = frame.size.width
        let height = frame.size.height

        let lineWidth: CGFloat = 20

        let center = CGPoint(x: width/2, y: height/2)
        let radius = (min(width, height) - lineWidth)/2

        let circularPath = UIBezierPath(arcCenter: center,
                                        radius: radius,
                                        startAngle: startAngle,
                                        endAngle: endAngle,
                                        clockwise: true)

        backgroundLayer.path = circularPath.cgPath
        backgroundLayer.fillColor = clearColor.cgColor
        backgroundLayer.strokeColor = backgroundCircleColor.cgColor
        backgroundLayer.lineWidth = 20
        layer.addSublayer(backgroundLayer)

        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = clearColor.cgColor
        progressLayer.strokeColor = UIColor.blue.cgColor
        progressLayer.lineWidth = 20
        progressLayer.lineCap = .round

        let gradientLayer = CAGradientLayer()
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 0.5)

        gradientLayer.colors = [startGradientColor.cgColor, endGradientColor.cgColor]
        gradientLayer.frame = bounds
        gradientLayer.mask = progressLayer

        layer.addSublayer(gradientLayer)

        textLayer.frame = CGRect(x: 0, y: 0, width: frame.width/2, height: 30)
        textLayer.position = CGPoint(x: frame.size.width/2, y: frame.size.height/2)
        textLayer.foregroundColor = UIColor.black.cgColor
        textLayer.fontSize = 20
        textLayer.alignmentMode = .center
        textLayer.string = "00:00:00"
        layer.addSublayer(textLayer)
    }

    func setProgress(progress: CGFloat) {
        DispatchQueue.main.async {
            self.progressLayer.strokeEnd = progress
        }
    }
}
