# Titolizer

Genera videos mp4 a partir de una imagen, un audio y un texto. No hay que instalar nada: la primera vez descarga ffmpeg solo.

## Cómo usarlo (Windows)

1. Descarga el proyecto: en GitHub, botón verde **Code → Download ZIP**, y descomprímelo.
2. Dentro de la carpeta `input`, crea una carpeta por cada video. **El nombre de la carpeta es el nombre del video final.** Por ejemplo `input/mi-video/`.
3. En cada carpeta pon estos 4 archivos:

   | Archivo | Qué es |
   |---|---|
   | `imagen.jpg` (o `.png`) | La imagen del video |
   | `audio.mp3` (o `.wav`, `.m4a`) | El audio. Si es más corto que el video, se repite |
   | `config.txt` | Una línea: `duracion=60` (minutos del video largo) |
   | `texto.txt` | El texto que aparece en el video corto |

4. Haz doble clic en **`Generar.bat`**.
   - La primera vez descarga ffmpeg (~80 MB), puede tardar unos minutos.
   - Si Windows muestra "SmartScreen", pulsa **Más información → Ejecutar de todas formas**.
5. Los videos quedan en la carpeta `output`.

## Qué genera

Por cada carpeta `input/<nombre>/`:

| Archivo | Descripción |
|---|---|
| `output/<nombre>.mp4` | 1920x1080, dura lo que dice `duracion`. La imagen se recorta para llenar el cuadro. Con audio, sin texto. |
| `output/<nombre>-short.mp4` | 1080x1920, 15 segundos, 60 fps. Imagen completa, con el texto, el audio y un zoom suave del 5%. |

## Notas

- Si un mp4 ya existe en `output`, se salta. Para regenerarlo, bórralo.
- Si a una carpeta le falta algo, avisa cuál y sigue con las demás.
- El video largo de una hora tarda pocos minutos en generarse.
- `texto.txt` puede tener varias líneas, acentos y símbolos.
- En Mac/Linux: `./Generar.sh` (necesita ffmpeg con `drawtext`, por ejemplo `brew install ffmpeg-full`).
