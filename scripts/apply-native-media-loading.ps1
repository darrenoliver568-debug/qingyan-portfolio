$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$sourceDir = Join-Path $root 'assets\optimized'
$responsiveDir = Join-Path $root 'assets\responsive'
New-Item -ItemType Directory -Force -Path $responsiveDir | Out-Null

function Save-JpegVariant([string]$sourcePath, [string]$targetPath, [int]$targetWidth) {
  $source = [System.Drawing.Image]::FromFile($sourcePath)
  try {
    if ($source.Width -le $targetWidth) { return }
    $targetHeight = [int][Math]::Round($source.Height * $targetWidth / $source.Width)
    $bitmap = New-Object System.Drawing.Bitmap($targetWidth, $targetHeight)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    try {
      $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
      $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
      $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
      $graphics.DrawImage($source, 0, 0, $targetWidth, $targetHeight)
      $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
      $parameters = New-Object System.Drawing.Imaging.EncoderParameters(1)
      $parameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]84)
      $bitmap.Save($targetPath, $codec, $parameters)
    } finally {
      $graphics.Dispose()
      $bitmap.Dispose()
    }
  } finally {
    $source.Dispose()
  }
}

$dimensions = @{}
Get-ChildItem -LiteralPath $sourceDir -Filter '*.jpg' | ForEach-Object {
  $image = [System.Drawing.Image]::FromFile($_.FullName)
  try { $dimensions[$_.Name] = @($image.Width, $image.Height) } finally { $image.Dispose() }
  Save-JpegVariant $_.FullName (Join-Path $responsiveDir ($_.BaseName + '-640.jpg')) 640
  Save-JpegVariant $_.FullName (Join-Path $responsiveDir ($_.BaseName + '-1200.jpg')) 1200
}

$version = '20261020-native'
Get-ChildItem -LiteralPath $root -Filter '*.html' | ForEach-Object {
  $path = $_.FullName
  $html = [IO.File]::ReadAllText($path)
  $html = $html -replace '<link rel="stylesheet" href="assets/css/site.css">(?:<style>.*?</style>)?', ('<link rel="stylesheet" href="assets/css/site.css?v=' + $version + '"><link rel="stylesheet" href="assets/css/final.css?v=' + $version + '">')
  $html = $html -replace '<link rel="preload" as="image" href="assets/optimized/illy-hero.jpg" fetchpriority="high">', ''
  $html = $html -replace 'assets/js/site.js(?:\?v=[^"]+)?', ('assets/js/site.js?v=' + $version)
  $html = $html -replace ' style="background-image:url\(''data:image/jpeg;base64,[^'']+''\);background-size:cover;background-position:center"', ''
  $html = $html -replace ' style="opacity:0"', ''

  $html = [regex]::Replace($html, '<img\b[^>]*\bsrc="assets/optimized/([^"]+\.jpg)"[^>]*>', {
    param($match)
    $tag = $match.Value
    $name = $match.Groups[1].Value
    if (-not $dimensions.ContainsKey($name)) { return $tag }
    $width = $dimensions[$name][0]
    $height = $dimensions[$name][1]
    if ($tag -notmatch '\bwidth=') { $tag = $tag -replace '<img', ('<img width="' + $width + '" height="' + $height + '"') }
    if ($tag -notmatch '\bloading=') { $tag = $tag -replace '<img', '<img loading="lazy" decoding="async"' }
    $stem = [IO.Path]::GetFileNameWithoutExtension($name)
    $candidates = @()
    if (Test-Path (Join-Path $responsiveDir ($stem + '-640.jpg'))) { $candidates += ('assets/responsive/' + $stem + '-640.jpg 640w') }
    if (Test-Path (Join-Path $responsiveDir ($stem + '-1200.jpg'))) { $candidates += ('assets/responsive/' + $stem + '-1200.jpg 1200w') }
    $candidates += ('assets/optimized/' + $name + ' ' + $width + 'w')
    if ($tag -notmatch '\bsrcset=') {
      $srcset = [string]::Join(', ', $candidates)
      $tag = $tag -replace ('src="assets/optimized/' + [regex]::Escape($name) + '"'), ('src="assets/optimized/' + $name + '" srcset="' + $srcset + '" sizes="(max-width: 900px) calc(100vw - 40px), 1120px"')
    }
    return $tag
  })

  $html = $html -replace '<div class="hero-media"><img loading="lazy" decoding="async"', '<div class="hero-media"><img loading="eager" decoding="async" fetchpriority="high"'
  $html = $html -replace '<section class="cover"><img loading="lazy" decoding="async"', '<section class="cover"><img loading="eager" decoding="async" fetchpriority="high"'
  $html = [regex]::Replace($html, '<video\b[^>]*>', {
    param($match)
    $tag = $match.Value -replace 'preload="metadata"', 'preload="none"'
    if ($tag -notmatch '\bloading=') { $tag = $tag -replace '<video', '<video loading="lazy"' }
    if ($tag -notmatch '\bwidth=') {
      if ($tag -match 'drama-poster') { $tag = $tag -replace '<video', '<video width="1080" height="1920"' }
      else { $tag = $tag -replace '<video', '<video width="1920" height="1080"' }
    }
    return $tag
  })
  $html = $html -replace '<source src="assets/video/([^"]+)"', '<source data-src="assets/video/$1"'
  [IO.File]::WriteAllText($path, $html, [Text.UTF8Encoding]::new($false))
}

Write-Output ('Responsive variants: ' + (Get-ChildItem -LiteralPath $responsiveDir -File).Count)
Write-Output ('Updated HTML files: ' + (Get-ChildItem -LiteralPath $root -Filter '*.html').Count)
