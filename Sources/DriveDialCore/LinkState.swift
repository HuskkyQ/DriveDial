import Foundation

public enum LinkState: Equatable, Sendable {
    case simulated(VehicleSnapshot)
    case connecting
    case disconnected
    case stale(VehicleSnapshot, age: TimeInterval)

    public var snapshot: VehicleSnapshot? {
        switch self {
        case .simulated(let snapshot), .stale(let snapshot, _):
            return snapshot
        case .connecting, .disconnected:
            return nil
        }
    }

    public var isLiveSimulation: Bool {
        if case .simulated = self { return true }
        return false
    }

    public var isStale: Bool {
        if case .stale = self { return true }
        return false
    }

    public var showsLastReading: Bool {
        switch self {
        case .simulated, .stale: return true
        case .connecting, .disconnected: return false
        }
    }

    /// This build never presents a Bluetooth session as connected.
    public var presentsBluetoothAsConnected: Bool { false }

    public var disclosure: String {
        switch self {
        case .simulated:
            return Copy.simulatedDisclosure
        case .connecting:
            return Copy.connectingDisclosure
        case .disconnected:
            return Copy.disconnectedDisclosure
        case .stale:
            return Copy.staleDisclosurePrefix
        }
    }

    /// Left-hand cluster status. The demo capsule is separate and always says 演示模式.
    public var readyLabel: String {
        switch self {
        case .simulated:
            return DesignSpec.Ready.text
        case .connecting:
            return Copy.connectingDisclosure
        case .disconnected:
            return Copy.disconnectedDisclosure
        case .stale:
            return Copy.staleDisclosurePrefix
        }
    }

    public var statusDetail: String {
        switch self {
        case .connecting:
            return "正在连接"
        case .disconnected:
            return "无法获取车辆数据"
        case .simulated, .stale:
            return "车辆数据"
        }
    }
}

/// Read-only vehicle readings.
/// A later Tesla BLE source may conform to this to display data.
/// Do not add vehicle commands here. This target does not speak a Tesla protocol
/// and does not request Bluetooth permission.
public protocol VehicleDataProvider: AnyObject {
    func current(now: Date) -> LinkState
}
