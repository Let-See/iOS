//
//  UIDevice+Extensions.swift
//
//
//  Created by Farshad Macbook M1 Pro on 4/18/22.
//

#if canImport(UIKit)
import UIKit

public extension UIDevice {
	var ipAddress: String {
		var address: String = .empty
		var ifaddr: UnsafeMutablePointer<ifaddrs>?
		guard getifaddrs(&ifaddr) == .zero else {
			return address
		}
		var ptr = ifaddr
		while ptr != nil {
			defer { ptr = ptr?.pointee.ifa_next }
			guard let interface = ptr?.pointee else { return .empty }
			let addrFamily = interface.ifa_addr.pointee.sa_family
			let adapters = ["en0", "en2", "en3", "en4", "pdp_ip0", "pdp_ip1", "pdp_ip2", "pdp_ip3"]
			if addrFamily == UInt8(AF_INET) || addrFamily == UInt8(AF_INET6) {
				let name: String = String(cString: (interface.ifa_name))
				if  adapters.contains(name) {
					var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
					getnameinfo(interface.ifa_addr, socklen_t((interface.ifa_addr.pointee.sa_len)), &hostname, socklen_t(hostname.count), nil, socklen_t(0), NI_NUMERICHOST)
					address = String(cString: hostname)
				}
			}
		}
		freeifaddrs(ifaddr)
		return address
	}
}
#endif
