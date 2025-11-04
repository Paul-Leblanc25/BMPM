$listener = New-Object System.Net.HttpListener
$prefix = "http://localhost:8082/"
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output ("Preview URL: " + $prefix)

function Get-ContentType([string]$path) {
  if ($path -match "\.html?$") { return "text/html" }
  elseif ($path -match "\.css$") { return "text/css" }
  elseif ($path -match "\.js$") { return "application/javascript" }
  elseif ($path -match "\.png$") { return "image/png" }
  elseif ($path -match "\.jpg$" -or $path -match "\.jpeg$") { return "image/jpeg" }
  else { return "application/octet-stream" }
}

while ($true) {
  $context = $listener.GetContext()
  $path = $context.Request.Url.AbsolutePath.TrimStart('/')
  if ([string]::IsNullOrEmpty($path)) { $path = "index.html" }
  $full = Join-Path (Get-Location) $path
  if (Test-Path $full) {
    $bytes = [System.IO.File]::ReadAllBytes($full)
    $context.Response.ContentType = Get-ContentType $full
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
  } else {
    $context.Response.StatusCode = 404
    $msg = [Text.Encoding]::UTF8.GetBytes("Not Found: $path")
    $context.Response.OutputStream.Write($msg, 0, $msg.Length)
  }
  $context.Response.Close()
}
