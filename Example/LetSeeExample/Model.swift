//
//  Model.swift
//  LetSeeExample
//
//  Created by Farshad Macbook M1 Pro on 5/4/22.
//

import Foundation
import LetSee
public struct Me {
	public let name: String
	public let family: String
	public init(
		name: String,
		family: String) {
			self.name = name
			self.family = family

		}
}

extension Me: LetSeeMockProviding {
	public static var mocks: Set<LetSeeMock> {
		[
			.defaultSuccess(name: "Normal User", data:
"""
{
 'name':'Farshad',
 'family': 'Jahanmanesh'
}
"""
					),

				.defaultFailure(name: "User Not Found", data:
"""
{
 'message':'User not found.'
}
"""
						),

				.defaultFailure(name: "User is Not Active", data:
"""
{
 'message':'User is Not Active.'
   }
"""
						),

				.defaultSuccess(name: "Admin User", data:
"""
{
  'name':'Farshad',
  'family': 'Jahanmanesh'
   }
"""
						),
		]
	}
}
