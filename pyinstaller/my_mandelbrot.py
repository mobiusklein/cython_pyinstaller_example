import sys
import matplotlib

matplotlib.use("agg")

from my_package import app
try:
    cmap_name = sys.argv[1]
except IndexError:
    cmap_name = 'jet'
print("Drawing Mandelbrot with color map %r" % (cmap_name,))
app.draw_mandelbrot(cmap_name)
