//
//  ArtworkViews.swift
//  Training
//
//  Created by ManhLD on 1/10/20.
//  Copyright © 2020 ManhLD. All rights reserved.
//

import Foundation
import MapKit

class ArtworkMarkerView: MKMarkerAnnotationView {
    
  override var annotation: MKAnnotation? {
        willSet {
            guard let artwork = newValue as? Artwork else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = artwork.markerTintColor
            if let imageName = artwork.imageName {
                glyphImage = UIImage(named: imageName)
            } else {
                glyphImage = nil
            }
        }
    }
    
}
