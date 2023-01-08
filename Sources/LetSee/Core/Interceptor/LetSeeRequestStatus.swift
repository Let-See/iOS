//
//  LetSeeRequestStatus.swift
//  LetSee
//
//  Created by Farshad Macbook M1 Pro on 5/3/22.
//

import Foundation
/**
This enumeration represents the different states a LetSeeRequest can be in.

- `loading`: The request is currently being loaded.
- `idle`: The request is not currently being processed.
- `active`: The request is currently being processed.
*/
public enum LetSeeRequestStatus {
	case loading
	case idle
	case active
}
