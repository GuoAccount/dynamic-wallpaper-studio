import Foundation

public enum WallpaperType: String, Codable, CaseIterable, Identifiable {
    case procedural
    case video
    case web
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .procedural: return "原生特效 (Procedural)"
        case .video: return "高清视频 (Video)"
        case .web: return "Web/WebGL (Web)"
        }
    }
}

public enum ProceduralStyle: String, Codable, CaseIterable, Identifiable {
    case cosmicNebula = "cosmic"
    case auroraFlow = "aurora"
    case ambientBokeh = "bokeh"
    case cyberGlow = "cyber"
    case minimalClock = "clock"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .cosmicNebula: return "🌌 浩瀚星云"
        case .auroraFlow: return "🌌 极光流彩"
        case .ambientBokeh: return "✨ 极简漫游"
        case .cyberGlow: return "🌆 赛博夜色"
        case .minimalClock: return "🕒 极简数字时钟"
        }
    }
    
    public var description: String {
        switch self {
        case .cosmicNebula: return "原生 GPU 极简高帧率星雨粒子，流畅梦幻"
        case .auroraFlow: return "自然流动翡翠极光与流彩夜空，极具艺术感"
        case .ambientBokeh: return "极简柔和漫游光斑与气晕，极度放松舒适"
        case .cyberGlow: return "霓虹地平线与极光线，复古赛博审美"
        case .minimalClock: return "4K 高帧率极简时间与柔光背景"
        }
    }
}

public struct WallpaperItem: Identifiable, Codable, Equatable {
    public let id: UUID
    public var title: String
    public var subtitle: String
    public var type: WallpaperType
    public var proceduralStyle: ProceduralStyle?
    public var url: URL?
    public var htmlContent: String?
    public var isPreset: Bool
    
    public init(
        id: UUID = UUID(),
        title: String,
        subtitle: String,
        type: WallpaperType,
        proceduralStyle: ProceduralStyle? = nil,
        url: URL? = nil,
        htmlContent: String? = nil,
        isPreset: Bool = false
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.type = type
        self.proceduralStyle = proceduralStyle
        self.url = url
        self.htmlContent = htmlContent
        self.isPreset = isPreset
    }
}

extension WallpaperItem {
    public static let presets: [WallpaperItem] = [
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
            title: "浩瀚星云",
            subtitle: "原生 GPU 极简高帧率星雨粒子",
            type: .procedural,
            proceduralStyle: .cosmicNebula,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
            title: "极光流彩",
            subtitle: "自然流动翡翠极光与流彩夜空",
            type: .procedural,
            proceduralStyle: .auroraFlow,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            title: "极简漫游",
            subtitle: "极简柔和漫游光斑与气晕",
            type: .procedural,
            proceduralStyle: .ambientBokeh,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            title: "赛博夜色",
            subtitle: "霓虹地平线与极光线",
            type: .procedural,
            proceduralStyle: .cyberGlow,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            title: "极简数字时钟",
            subtitle: "4K 高帧率极简时间与柔光背景",
            type: .procedural,
            proceduralStyle: .minimalClock,
            isPreset: true
        )
    ]
}
