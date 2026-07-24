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
    case matrixRain = "matrix"
    case cyberGrid = "cyber"
    case minimalClock = "clock"
    
    public var id: String { rawValue }
    
    public var title: String {
        switch self {
        case .cosmicNebula: return "🌌 浩瀚星云"
        case .matrixRain: return "🟢 黑客数字雨"
        case .cyberGrid: return "🌆 赛博朋克网格"
        case .minimalClock: return "🕒 极简动态时钟"
        }
    }
    
    public var description: String {
        switch self {
        case .cosmicNebula: return "动态粒子星云与悬浮星体，GPU 高效并行计算"
        case .matrixRain: return "经典绿光代码流落特效，支持自定义雨滴速率"
        case .cyberGrid: return "80s 复古霓虹透视网格与极光漂移"
        case .minimalClock: return "4K 高帧率极简时间与渐变光束背景"
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
            title: "黑客帝国",
            subtitle: "Matrix 代码雨落流光",
            type: .procedural,
            proceduralStyle: .matrixRain,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
            title: "赛博网格",
            subtitle: "霓虹透视穿梭线",
            type: .procedural,
            proceduralStyle: .cyberGrid,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
            title: "极简数字时钟",
            subtitle: "柔和渐变与优雅时钟",
            type: .procedural,
            proceduralStyle: .minimalClock,
            isPreset: true
        ),
        WallpaperItem(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
            title: "HTML5 流体粒子",
            subtitle: "Web Canvas 硬件加速流体特效",
            type: .web,
            htmlContent: defaultFluidWebHTML,
            isPreset: true
        )
    ]
}

private let defaultFluidWebHTML = """
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  body { margin: 0; overflow: hidden; background: #0b0c10; }
  canvas { display: block; width: 100vw; height: 100vh; }
</style>
</head>
<body>
<canvas id="c"></canvas>
<script>
  const canvas = document.getElementById('c');
  const ctx = canvas.getContext('2d');
  let width, height, particles = [];
  
  function resize() {
    width = canvas.width = window.innerWidth;
    height = canvas.height = window.innerHeight;
  }
  window.addEventListener('resize', resize);
  resize();
  
  for(let i=0; i<80; i++) {
    particles.push({
      x: Math.random() * width,
      y: Math.random() * height,
      r: Math.random() * 3 + 1,
      vx: (Math.random() - 0.5) * 0.8,
      vy: (Math.random() - 0.5) * 0.8,
      hue: Math.random() * 60 + 200
    });
  }
  
  function draw() {
    ctx.fillStyle = 'rgba(11, 12, 16, 0.2)';
    ctx.fillRect(0, 0, width, height);
    
    for(let i=0; i<particles.length; i++) {
      let p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      if(p.x < 0 || p.x > width) p.vx *= -1;
      if(p.y < 0 || p.y > height) p.vy *= -1;
      
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.r, 0, Math.PI * 2);
      ctx.fillStyle = 'hsla(' + p.hue + ', 80%, 65%, 0.8)';
      ctx.shadowBlur = 12;
      ctx.shadowColor = 'hsla(' + p.hue + ', 80%, 65%, 0.8)';
      ctx.fill();
    }
    requestAnimationFrame(draw);
  }
  draw();
</script>
</body>
</html>
"""
