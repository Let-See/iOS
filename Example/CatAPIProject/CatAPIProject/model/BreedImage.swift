//
//  BreedImage.swift
//  BreedImage
//
//  Created by Karin Prater on 20.08.21.
//

import Foundation

/*
 "image": {
   "height": 1445,
   "id": "0XYvRd7oD",
   "url": "https://cdn2.thecatapi.com/images/0XYvRd7oD.jpg",
   "width": 1204
 },
 */

public struct BreedImage: Codable {
	public let height: Int?
	public let id: String?
	public let url: String?
	public let width: Int?
    
}
