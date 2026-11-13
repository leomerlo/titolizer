@echo off
chcp 65001 >nul
setlocal
set "ROOT=%~dp0"
cd /d "%ROOT%"

rem Primera vez: baja ffmpeg (~80 MB) a esta carpeta
if not exist ffmpeg.exe (
  echo Descargando ffmpeg, espera unos minutos...
  curl -L -o ffmpeg.zip https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip || goto :error
  tar -xf ffmpeg.zip || goto :error
  for /d %%d in (ffmpeg-*) do copy "%%d\bin\ffmpeg.exe" ffmpeg.exe >nul
  for /d %%d in (ffmpeg-*) do rmdir /s /q "%%d"
  del ffmpeg.zip
)

if not exist output mkdir output
rem input\<nombre>\ -> output\<nombre>.mp4 (largo, 1920x1080, sin texto) y output\<nombre>-short.mp4 (1080x1920, 15 s, zoom + texto)
rem Si un mp4 ya existe se salta; borralo para regenerar
for /d %%d in (input\*) do call 

:render
set "NAME=%~1"
pushd "%ROOT%input\%NAME%"
set "MIN=" & set "IMG=" & set "AUD="
for /f "tokens=1,* delims==" %%a in (config.txt) do if /i "%%a"=="duracion" set /a MIN=%%b
for %%f in (imagen.*) do set "IMG=%%f"
for %%f in (audio.*)  do set "AUD=%%f"
if not defined MIN (echo [%NAME%] Falta duracion=... en config.txt & popd & exit /b 1)
if not defined IMG (echo [%NAME%] Falta imagen.jpg / imagen.png & popd & exit /b 1)
if not defined AUD (echo [%NAME%] Falta audio.mp3 / audio.wav & popd & exit /b 1)

rem 1) duracion del config, 1920x1080, imagen recortada verticalmente para llenar el ancho, 1 fps
set /a SEG=MIN*60
set "OUT=%ROOT%output\%NAME%.mp4"
set "INOPT=-loop 1 -framerate 1"
set "VF=scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p"
call :ffmpeg

rem 2) 15 s, imagen completa en 1080x1920 + texto, zoom suave de 5 por ciento desde el centro, 60 fps
set "SEG=15"
set "OUT=%ROOT%output\%NAME%-short.mp4"
set "INOPT="
set "VF=scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,scale=4320:7680,zoompan=z='1+0.05*on/900':x='iw/2-iw/zoom/2':y='ih/2-ih/zoom/2':d=900:s=2160x3840:fps=60,scale=1080:1920:flags=lanczos,drawtext=fontfile='C\:/Windows/Fonts/arial.ttf':textfile=texto.txt:fontcolor=white:fontsize=64:box=1:boxcolor=black@0.5:boxborderw=20:x=(w-text_w)/2:y=h-text_h-80,format=yuv420p"
call :ffmpeg
popd
exit /b 0

:ffmpeg
if exist "%OUT%" (echo [%NAME%] %OUT% ya existe, se salta & exit /b 0)
echo [%NAME%] Generando %OUT% (%SEG% s)...
"%ROOT%ffmpeg.exe" -y %INOPT% -i "%IMG%" -stream_loop -1 -i "%AUD%" -t %SEG% -vf "%VF%" -c:v libx264 -tune stillimage -preset veryfast -c:a aac -b:a 192k -movflags +faststart "%OUT%"
if errorlevel 1 (echo [%NAME%] FALLO & del "%OUT%" 2>nul)
exit /b 0

:error
echo Algo fallo. Avisame con una captura de esta ventana.
pause
exit /b 1
