////  CryptoSwift
//
//  Copyright (C) 2014-2019 Marcin Krzyżanowski <marcin@krzyzanowskim.com>
//  This software is provided 'as-is', without any express or implied warranty.
//
//  In no event will the authors be held liable for any damages arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,including commercial applications, and to alter it and redistribute it freely, subject to the following restrictions:
//
//  - The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation is required.
//  - Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
//  - This notice may not be removed or altered from any source or binary distribution.
//

import Foundation

public final class RIPEMD160: DigestType {
	static let digestLength: Int = 20
    static let blockSize: Int = 64
	fileprivate static let hashInitialValue: Array<UInt32> = [0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476, 0xc3d2e1f0]

	fileprivate var accumulated = Array<UInt8>()
	fileprivate var processedBytesTotalCount: Int = 0
	fileprivate var accumulatedHash: ContiguousArray<UInt32> = RIPEMD160.hashInitialValue

	public init() {
	}

    func calculate(for bytes: Array<UInt8>) -> Array<UInt8> {
		do {
			return try update(withBytes: bytes.slice, isLast: true)
		} catch {
			return []
		}
	}

	fileprivate func process(block chunk: ArraySlice<UInt8>, currentHash hh: inout ContiguousArray<UInt32>) {
		// TODO:
	}
}

extension RIPEMD160: Updatable {
	@discardableResult
	public func update(withBytes bytes: ArraySlice<UInt8>, isLast: Bool = false) throws -> Array<UInt8> {
        accumulated += bytes

		if isLast {
		}

		var processedBytes = 0
		for chunk in accumulated.batched(by: RIPEMD160.blockSize) {
			if isLast || (accumulated.count - processedBytes) >= RIPEMD160.blockSize {
				process(block: chunk, currentHash: &accumulatedHash)
				processedBytes += chunk.count
			}
		}
		accumulated.removeFirst(processedBytes)
		processedBytesTotalCount += processedBytes

		// output current hash
		var result = Array<UInt8>(repeating: 0, count: SHA1.digestLength)
		var pos = 0
		for idx in 0..<accumulatedHash.count {
			let h = accumulatedHash[idx]
			result[pos + 0] = UInt8((h >> 24) & 0xff)
			result[pos + 1] = UInt8((h >> 16) & 0xff)
			result[pos + 2] = UInt8((h >> 8) & 0xff)
			result[pos + 3] = UInt8(h & 0xff)
			pos += 4
		}

		// reset hash value for instance
		if isLast {
			accumulatedHash = SHA1.hashInitialValue
		}

		return result
	}
}
