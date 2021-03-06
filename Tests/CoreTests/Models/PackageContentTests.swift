//
//  PackageContentTests.swift
//
//
//  Created by Marino Felipe on 29.12.20.
//

import XCTest
import TestSupport
@testable import Core

final class PackageContentTests: XCTestCase {
    private let jsonDecoder: JSONDecoder = .init()

    func testDecodingFromJSON() throws {
        let fixtureData = try dataFromJSON(named: "package_full", bundle: .module)
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: fixtureData)

        let expectedPackageContent = PackageContent(
            name: "SomePackage",
            platforms: [
                .init(
                    platformName: "ios",
                    version: "9.0"
                ),
                .init(
                    platformName: "macos",
                    version: "10.15"
                )
            ],
            products: [
                .init(
                    name: "Product1",
                    targets: [
                        "Target1",
                        "Target2"
                    ],
                    kind: .library(.automatic)
                ),
                .init(
                    name: "Product2",
                    targets: [
                        "Target1",
                        "Target3"
                    ],
                    kind: .library(.static)
                ),
                .init(
                    name: "Product3",
                    targets: [
                        "Target2"
                    ],
                    kind: .executable
                ),
                .init(
                    name: "Product4",
                    targets: [
                        "Target1"
                    ],
                    kind: .library(.dynamic)
                )
            ],
            dependencies: [
                .init(
                    name: "swift-argument-parser",
                    urlString: "https://github.com/apple/swift-argument-parser",
                    requirement: .init(
                        range: [
                            .init(
                                lowerBound: "0.3.0",
                                upperBound: "0.4.0"
                            )
                        ],
                        revision: [],
                        branch: []
                    )
                )
            ],
            targets: [
                .init(
                    name: "Target1",
                    dependencies: [
                        .product(
                            [
                                .name("swift-argument-parser")
                            ]
                        )
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target2",
                    dependencies: [
                        .byName(
                            [
                                .name("Target1")
                            ]
                        )
                    ],
                    kind: .binary
                ),
                .init(
                    name: "Target3",
                    dependencies: [
                        .product(
                            [
                                .name("ArgumentParser"),
                                .name("swift-argument-parser")
                            ]
                        ),
                        .target(
                            [
                                .name("Target1")
                            ]
                        )
                    ],
                    kind: .test
                )
            ],
            swiftLanguageVersions: [
                "5"
            ]
        )

        XCTAssertEqual(
            packageContent,
            expectedPackageContent
        )
    }

    func testIsDynamicLibrary() throws {
        let packageContent = PackageContent(
            name: "SomePackage",
            platforms: [
                .init(
                    platformName: "ios",
                    version: "9.0"
                ),
                .init(
                    platformName: "macos",
                    version: "10.15"
                )
            ],
            products: [
                .init(
                    name: "Product1",
                    targets: [
                        "Target1",
                        "Target2"
                    ],
                    kind: .library(.automatic)
                ),
                .init(
                    name: "Product2",
                    targets: [
                        "Target1",
                        "Target3"
                    ],
                    kind: .library(.static)
                ),
                .init(
                    name: "Product3",
                    targets: [
                        "Target2"
                    ],
                    kind: .executable
                ),
                .init(
                    name: "Product4",
                    targets: [
                        "Target1"
                    ],
                    kind: .library(.dynamic)
                )
            ],
            dependencies: [],
            targets: [],
            swiftLanguageVersions: []
        )

        packageContent.products.forEach { product in
            XCTAssertEqual(product.isDynamicLibrary, product == packageContent.products.last)
        }
    }

    func testDifferentTypesOfDependencyRequirement() throws {
        let fixtureData = try dataFromJSON(named: "package_with_multiple_dependencies", bundle: .module)
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: fixtureData)

        let expectedPackageContent = PackageContent(
            name: "SomePackage",
            platforms: [],
            products: [],
            dependencies: [
                .init(
                    name: "swift-argument-parser",
                    urlString: "https://github.com/apple/swift-argument-parser",
                    requirement: .init(
                        range: [
                            .init(
                                lowerBound: "0.3.0",
                                upperBound: "0.4.0"
                            )
                        ],
                        revision: [],
                        branch: []
                    )
                ),
                .init(
                    name: "SomeDependency",
                    urlString: "https://github.com/someDev/some-dependency",
                    requirement: .init(
                        range: [],
                        revision: [
                            "123456CrazyHash"
                        ],
                        branch: []
                    )
                ),
                .init(
                    name: "SomeOtherDependency",
                    urlString: "https://github.com/someOtherDev/some-other-dependency",
                    requirement: .init(
                        range: [],
                        revision: [],
                        branch: [
                            "some-fork-123"
                        ]
                    )
                )
            ],
            targets: [],
            swiftLanguageVersions: []
        )

        XCTAssertEqual(
            packageContent,
            expectedPackageContent
        )
    }

    func testWhenTargetDependencyIsOfTypeTargetWithNestedPlatforms() throws {
        let fixtureData = try dataFromJSON(
            named: "package_with_custom_target_dependency",
            bundle: .module
        )
        let packageContent = try jsonDecoder.decode(PackageContent.self, from: fixtureData)

        let expectedPackageContent = PackageContent(
            name: "SomePackage",
            platforms: [],
            products: [],
            dependencies: [],
            targets: [
                .init(
                    name: "Target1",
                    dependencies: [
                        .target(
                            [
                                .name("Target2"),
                                .platforms(
                                    .init(
                                        platformNames: [
                                            "ios"
                                        ]
                                    )
                                )
                            ]
                        )
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target2",
                    dependencies: [
                        .product(
                            [
                                .name("Product3"),
                                .platforms(
                                    .init(
                                        platformNames: [
                                            "ios"
                                        ]
                                    )
                                )
                            ]
                        )
                    ],
                    kind: .regular
                ),
                .init(
                    name: "Target3",
                    dependencies: [
                        .byName(
                            [
                                .name("Name4"),
                                .platforms(
                                    .init(
                                        platformNames: [
                                            "ios"
                                        ]
                                    )
                                )
                            ]
                        )
                    ],
                    kind: .regular
                )
            ],
            swiftLanguageVersions: []
        )

        XCTAssertEqual(
            packageContent,
            expectedPackageContent
        )
    }
}
