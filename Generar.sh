#!/bin/bash
# Equivalente de Generar.bat para Mac/Linux. Usa el ffmpeg del sistema.
# Por cada input/<nombre>/ genera output/<nombre>.mp4 (largo, 1920x1080, sin texto) y output/<nombre>-short.mp4 (1080x1920, 15 s, zoom + texto)
cd "$(dirname "$0")" || exit 1
mkdir -p output

FONT=/System/Library/Fonts/Supplemental/Arial.ttf
TEXT="drawtext=fontfile=$FONT:textfile=texto.txt:fontcolor=white:fontsize=64:box=1:boxcolor=black@0.5:boxborderw=20:x=(w-text_w)/2:y=h-text_h-80,"
if ! ffmpeg -hide_banner -filters 2>/dev/null | grep -q drawtext; then
  echo "AVISO: este ffmpeg no tiene drawtext, los videos saldran sin texto"; TEXT=""
fi

ROOT=$PWD
for dir in input/*/; do
  name=$(basename "$dir")
  (
    cd "$dir" || exit 1
    min=$(sed -n 's/^duracion=//p' config.txt 2>/dev/null | head -1)
    img=$(ls imagen.* 2>/dev/null | head -1)
    aud=$(ls audio.* 2>/dev/null | head -1)
    [ -n "$min" ] || { echo "[$name] Falta duracion=... en config.txt"; exit 1; }
    [ -n "$img" ] || { echo "[$name] Falta imagen.jpg / imagen.png"; exit 1; }
    [ -n "$aud" ] || { echo "[$name] Falta audio.mp3 / audio.wav"; exit 1; }

    render() { # $1=salida $2=segundos $3=filtro $4=opciones de entrada de la imagen
      [ -e "$1" ] && { echo "[$name] $(basename "$1") ya existe, se salta"; return; }
      echo "[$name] Generando $(basename "$1") ($2 s)..."
      ffmpeg -v error -stats -y $4 -i "$img" -stream_loop -1 -i "$aud" -t "$2" -vf "$3" \
        -c:v libx264 -tune stillimage -preset veryfast -c:a aac -b:a 192k -movflags +faststart "$1" \
        || { echo "[$name] FALLO $(basename "$1")"; rm -f "$1"; }
    }

    # 1) duracion del config, 1920x1080, imagen recortada verticalmente para llenar el ancho, 1 fps
    render "$ROOT/output/$name.mp4" $((min * 60)) \
      "scale=1920:1080:force_original_aspect_ratio=increase,crop=1920:1080,format=yuv420p" "-loop 1 -framerate 1"
    # 2) 15 s, imagen completa en 1080x1920 + texto, zoom suave de 5% desde el centro, 60 fps
    render "$ROOT/output/$name-short.mp4" 15 \
      "scale=1080:1920:force_original_aspect_ratio=decrease,pad=1080:1920:(ow-iw)/2:(oh-ih)/2,scale=4320:7680,zoompan=z='1+0.05*on/900':x='iw/2-iw/zoom/2':y='ih/2-ih/zoom/2':d=900:s=2160x3840:fps=60,scale=1080:1920:flags=lanczos,${TEXT}format=yuv420p"
  )
done
echo "Terminado. Videos en la carpeta output."
