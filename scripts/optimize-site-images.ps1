$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $root 'assets\images'
$targetDir = Join-Path $root 'assets\optimized'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null

$quality = 88L
$jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
  Where-Object { $_.MimeType -eq 'image/jpeg' }
$encoder = [System.Drawing.Imaging.Encoder]::Quality
$encoderParams = New-Object System.Drawing.Imaging.EncoderParameters(1)
$encoderParams.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter($encoder, $quality)

$map = @{}
Get-ChildItem -LiteralPath $sourceDir -File |
  Where-Object { $_.Name -ne 'douyin-qr.jpg' -and $_.Length -gt 100KB } |
  ForEach-Object {
    $image = [System.Drawing.Image]::FromFile($_.FullName)
    try {
      $scale = [Math]::Min(1.0, [Math]::Min(1800.0 / $image.Width, 3200.0 / $image.Height))
      $width = [Math]::Max(1, [int][Math]::Round($image.Width * $scale))
      $height = [Math]::Max(1, [int][Math]::Round($image.Height * $scale))
      $bitmap = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format24bppRgb)
      try {
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
          $graphics.Clear([System.Drawing.Color]::White)
          $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
          $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
          $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
          $graphics.DrawImage($image, 0, 0, $width, $height)
        } finally {
          $graphics.Dispose()
        }
        $targetName = [System.IO.Path]::GetFileNameWithoutExtension($_.Name) + '.jpg'
        $targetPath = Join-Path $targetDir $targetName
        $bitmap.Save($targetPath, $jpegCodec, $encoderParams)
        $map[('assets/images/' + $_.Name)] = ('assets/optimized/' + $targetName)
      } finally {
        $bitmap.Dispose()
      }
    } finally {
      $image.Dispose()
    }
  }

$utf8 = New-Object System.Text.UTF8Encoding($false)
Get-ChildItem -LiteralPath $root -Filter '*.html' -File | ForEach-Object {
  $text = [System.IO.File]::ReadAllText($_.FullName)
  foreach ($entry in $map.GetEnumerator()) {
    $text = $text.Replace($entry.Key, $entry.Value)
  }
  [System.IO.File]::WriteAllText($_.FullName, $text, $utf8)
}

$sourceBytes = (Get-ChildItem -LiteralPath $sourceDir -File | Measure-Object Length -Sum).Sum
$targetBytes = (Get-ChildItem -LiteralPath $targetDir -File | Measure-Object Length -Sum).Sum
[pscustomobject]@{
  Converted = $map.Count
  OriginalMB = [Math]::Round($sourceBytes / 1MB, 2)
  OptimizedMB = [Math]::Round($targetBytes / 1MB, 2)
}
