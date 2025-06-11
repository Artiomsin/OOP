//
//  SocialPlanningKitTests.swift
//  SocialPlanningKitTests
//
//  Created by Artem on 29.05.25.
//
import CoreLocation
import XCTest
@testable import event_planning_app
import SocialPlanningKit

final class MapViewModelTests: XCTestCase {

    var viewModel: MapViewModel!

    override func setUp() {
        super.setUp()
        viewModel = MapViewModel()
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertNil(viewModel.currentLocation, "currentLocation должен быть nil при инициализации")
        XCTAssertEqual(viewModel.friendsLocations.count, 0, "Должно быть 0 друзей при инициализации")
    }

    func testIsNearbyReturnsTrueWhenClose() {
        let userLocation = CLLocationCoordinate2D(latitude: 53.9, longitude: 27.55)
        viewModel.currentLocation = userLocation
        
        let closeFriendLocation = CLLocationCoordinate2D(latitude: 53.9001, longitude: 27.5501)
        XCTAssertTrue(viewModel.isNearby(closeFriendLocation))
    }

    func testIsNearbyReturnsFalseWhenFar() {
        let userLocation = CLLocationCoordinate2D(latitude: 53.9, longitude: 27.55)
        viewModel.currentLocation = userLocation
        
        let farFriendLocation = CLLocationCoordinate2D(latitude: 53.95, longitude: 27.6)
        XCTAssertFalse(viewModel.isNearby(farFriendLocation))
    }
}
