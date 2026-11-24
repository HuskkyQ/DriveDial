import Foundation

/// User-facing Chinese copy. The instrument never claims a Bluetooth link is up.
public enum Copy {
    public static let simulatedDisclosure = "演示模式"
    public static let disconnectedDisclosure = "已断开"
    public static let connectingDisclosure = "连接中"
    public static let staleDisclosurePrefix = "数据已过期"
    public static let themeBlockedWhileMoving = "行驶中不可切换主题。请先停车后再更改仪表主题。"
    public static let noAudio = "网页里的播放按钮只是演示界面，不会真实放歌，也不控制手机或车机的媒体系统。"
    public static let simulatedMap = "示意地图 · 不连接真实地图服务"
    public static let simulatedMedia = "模拟 · 非实况"
    public static let artNote = "车模使用 v6 源稿中的后上方与正俯视位图，按原像素比例放入设计框，不拉伸。"
    public static let nameNote = "名称「行仪 / DriveDial」尚未确认，可以再改。"
    public static let readOnlyNote = "本阶段只显示模拟读数，不连接蓝牙，不控制车辆。"
    public static let unavailable = "--"
    public static let appName = "行仪"
    public static let tripTitle = "本次行程"
    public static let galleryTitle = "状态总览"
    public static let noRoute = "没有模拟路线"
}
