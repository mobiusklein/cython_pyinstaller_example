cimport cython
cimport numpy as np

np.import_array()

import numpy as np


def mandelbrot(zmin, zmax, m, n, int tmax=256):
    cdef:
        np.ndarray[np.complex128_t, ndim=2] M
        np.ndarray[np.complex128_t, ndim=2] Z, C
        size_t t, i, j
        int cond
    xs = np.linspace(zmin.real, zmax.real, n)
    ys = np.linspace(zmin.imag, zmax.imag, m)

    X, Y = np.meshgrid(xs, ys)
    Z = X + 1j * Y
    C = np.copy(Z)
    M = np.ones_like(Z) * tmax

    for t in range(tmax):
        for i in range(Z.shape[0]):
            for j in range(Z.shape[1]):
                cond = abs(Z[i, j]) <= 2.
                if cond:
                    Z[i, j] = Z[i, j] ** 2 + C[i, j]
                else:
                    M[i, j] = M[i, j] - 1
    return M.astype(float)
