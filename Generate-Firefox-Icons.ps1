$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$icons = Join-Path $PSScriptRoot 'firefox-extension\icons'
New-Item -ItemType Directory -Path $icons -Force | Out-Null

function New-RoundedRectangle([System.Drawing.RectangleF]$rectangle, [float]$radius) {
  $path = [Drawing.Drawing2D.GraphicsPath]::new()
  $diameter = $radius * 2
  $path.AddArc($rectangle.X, $rectangle.Y, $diameter, $diameter, 180, 90)
  $path.AddArc($rectangle.Right - $diameter, $rectangle.Y, $diameter, $diameter, 270, 90)
  $path.AddArc($rectangle.Right - $diameter, $rectangle.Bottom - $diameter, $diameter, $diameter, 0, 90)
  $path.AddArc($rectangle.X, $rectangle.Bottom - $diameter, $diameter, $diameter, 90, 90)
  $path.CloseFigure()
  return $path
}

$masterSize = 512
$master = [Drawing.Bitmap]::new($masterSize, $masterSize, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
$graphics = [Drawing.Graphics]::FromImage($master)
$graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.Clear([Drawing.Color]::Transparent)

$background = New-RoundedRectangle ([Drawing.RectangleF]::new(24, 24, 464, 464)) 112
$accent = [Drawing.SolidBrush]::new([Drawing.ColorTranslator]::FromHtml('#10A37F'))
$graphics.FillPath($accent, $background)

$white = [Drawing.Color]::White
$pen = [Drawing.Pen]::new($white, 36)
$pen.StartCap = [Drawing.Drawing2D.LineCap]::Round
$pen.EndCap = [Drawing.Drawing2D.LineCap]::Round
$pen.LineJoin = [Drawing.Drawing2D.LineJoin]::Round
$graphics.DrawLine($pen, 156, 112, 156, 284)
$graphics.DrawLines($pen, [Drawing.Point[]]@(
  [Drawing.Point]::new(108, 236),
  [Drawing.Point]::new(156, 284),
  [Drawing.Point]::new(204, 236)
))
$graphics.DrawLines($pen, [Drawing.Point[]]@(
  [Drawing.Point]::new(232, 260),
  [Drawing.Point]::new(292, 260),
  [Drawing.Point]::new(292, 172),
  [Drawing.Point]::new(360, 172)
))
$graphics.DrawLines($pen, [Drawing.Point[]]@(
  [Drawing.Point]::new(292, 260),
  [Drawing.Point]::new(292, 348),
  [Drawing.Point]::new(360, 348)
))
$dotBrush = [Drawing.SolidBrush]::new($white)
$graphics.FillEllipse($dotBrush, 360, 144, 56, 56)
$graphics.FillEllipse($dotBrush, 360, 320, 56, 56)

foreach ($size in 16, 32, 48, 96, 128) {
  $bitmap = [Drawing.Bitmap]::new($size, $size, [Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $target = [Drawing.Graphics]::FromImage($bitmap)
  $target.CompositingMode = [Drawing.Drawing2D.CompositingMode]::SourceCopy
  $target.CompositingQuality = [Drawing.Drawing2D.CompositingQuality]::HighQuality
  $target.InterpolationMode = [Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $target.PixelOffsetMode = [Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $target.DrawImage($master, 0, 0, $size, $size)
  $target.Dispose()
  $bitmap.Save((Join-Path $icons "icon-$size.png"), [Drawing.Imaging.ImageFormat]::Png)
  $bitmap.Dispose()
}

$dotBrush.Dispose()
$pen.Dispose()
$accent.Dispose()
$background.Dispose()
$graphics.Dispose()
$master.Dispose()
