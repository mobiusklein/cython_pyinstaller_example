from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize

import numpy

cython_directives = {
    'embedsignature': True,
}

extensions = cythonize([
    Extension(name='my_package.calc',
              sources=["my_package/calc.pyx"],
              include_dirs=[numpy.get_include()]),
    Extension(name='my_package.app',
              sources=["my_package/app.pyx"],
              include_dirs=[numpy.get_include()])
], compiler_directives=cython_directives)


setup(name='my_package',
      version='0.0.1',
      zip_safe=False,
      include_package_data=True,
      packages=find_packages(),
      ext_modules=extensions)
