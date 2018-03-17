rm -rf ./build/ ./dist/
echo "Beginning build"
python -m PyInstaller -c ./my_mandelbrot.py -D \
    --exclude-module _tkinter \
    --exclude-module PyQt4 \
    --exclude-module PyQt5 \
    --exclude-module IPython \
    --workpath build --distpath dist \
    --additional-hooks-dir ./
