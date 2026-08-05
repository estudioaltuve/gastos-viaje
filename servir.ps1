# Servidor local para probar la app desde el celular por WiFi.
# No sale a internet: sirve los archivos de esta carpeta a la red de casa.
# Uso:  boton derecho sobre el archivo -> "Ejecutar con PowerShell"
#       o desde una consola:  .\servir.ps1

param([int]$Puerto = 8080)

$Raiz = $PSScriptRoot
if (-not $Raiz) { $Raiz = (Get-Location).Path }

$mime = @{
  ".html"        = "text/html; charset=utf-8"
  ".js"          = "application/javascript; charset=utf-8"
  ".json"        = "application/json; charset=utf-8"
  ".webmanifest" = "application/manifest+json; charset=utf-8"
  ".css"         = "text/css; charset=utf-8"
  ".png"         = "image/png"
  ".svg"         = "image/svg+xml"
  ".ico"         = "image/x-icon"
}

$ip = (Get-NetIPAddress -AddressFamily IPv4 |
       Where-Object { $_.InterfaceAlias -notmatch 'Loopback' -and $_.IPAddress -notmatch '^169\.' } |
       Select-Object -First 1).IPAddress
if (-not $ip) { $ip = "127.0.0.1" }

try {
  $listener = New-Object System.Net.Sockets.TcpListener ([System.Net.IPAddress]::Any, $Puerto)
  $listener.Start()
} catch {
  Write-Host "No pude abrir el puerto $Puerto : $($_.Exception.Message)" -ForegroundColor Red
  Write-Host "Proba con otro puerto:  .\servir.ps1 -Puerto 8090"
  return
}

Write-Host ""
Write-Host "  Servidor levantado." -ForegroundColor Green
Write-Host "  Desde el celular, con el mismo WiFi, entra a:" -ForegroundColor Green
Write-Host ""
Write-Host "      http://$ip`:$Puerto" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Ctrl+C para cortar." -ForegroundColor DarkGray
Write-Host ""

function Send-Respuesta($stream, [int]$codigo, [string]$estado, [string]$tipo, [byte[]]$cuerpo) {
  $head = "HTTP/1.1 $codigo $estado`r`n" +
          "Content-Type: $tipo`r`n" +
          "Content-Length: $($cuerpo.Length)`r`n" +
          "Cache-Control: no-store`r`n" +
          "Connection: close`r`n`r`n"
  $hb = [System.Text.Encoding]::ASCII.GetBytes($head)
  $stream.Write($hb, 0, $hb.Length)
  if ($cuerpo.Length -gt 0) { $stream.Write($cuerpo, 0, $cuerpo.Length) }
  $stream.Flush()
}

try {
  while ($true) {
    $client = $listener.AcceptTcpClient()
    try {
      $stream = $client.GetStream()
      $reader = New-Object System.IO.StreamReader($stream, [System.Text.Encoding]::ASCII)
      $linea = $reader.ReadLine()
      if (-not $linea) { $client.Close(); continue }

      # descarto el resto de los encabezados
      while ($true) { $h = $reader.ReadLine(); if ($null -eq $h -or $h -eq "") { break } }

      $partes = $linea -split ' '
      $ruta = ($partes[1] -split '\?')[0]
      $ruta = [System.Uri]::UnescapeDataString($ruta)
      if ($ruta -eq "/") { $ruta = "/index.html" }

      $rel = $ruta.TrimStart('/').Replace('/', '\')
      $full = Join-Path $Raiz $rel
      $ok = $false
      if ($rel -notmatch '\.\.' -and (Test-Path $full -PathType Leaf)) {
        $res = (Resolve-Path $full).Path
        if ($res.StartsWith((Resolve-Path $Raiz).Path, [StringComparison]::OrdinalIgnoreCase)) { $ok = $true }
      }

      if ($ok) {
        $ext = [System.IO.Path]::GetExtension($res).ToLower()
        $tipo = $mime[$ext]
        if (-not $tipo) { $tipo = "application/octet-stream" }
        $bytes = [System.IO.File]::ReadAllBytes($res)
        Send-Respuesta $stream 200 "OK" $tipo $bytes
        Write-Host ("  200  " + $ruta) -ForegroundColor DarkGray
      } else {
        $b = [System.Text.Encoding]::UTF8.GetBytes("No encontrado")
        Send-Respuesta $stream 404 "Not Found" "text/plain; charset=utf-8" $b
        Write-Host ("  404  " + $ruta) -ForegroundColor DarkYellow
      }
    } catch {
      # conexion cortada por el cliente: seguimos
    } finally {
      $client.Close()
    }
  }
} finally {
  $listener.Stop()
  Write-Host "Servidor detenido."
}
