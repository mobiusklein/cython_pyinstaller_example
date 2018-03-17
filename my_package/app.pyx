import matplotlib
from matplotlib import pyplot as plt, cm

from my_package import calc


def draw_mandelbrot(cmap_name='viridis'):
    zmin = -1.3 - 1j * 1.3
    zmax = 1.3 + 1j * 1.3

    M = calc.mandelbrot(zmin, zmax, m=1024, n=1024)
    name = "mandelbrot.png"
    cmap = getattr(cm, cmap_name, cm.jet)
    plt.imsave(name, M, cmap=cmap, origin='lower')
