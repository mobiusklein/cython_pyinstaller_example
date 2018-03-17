# Building a bundled application with Cython and PyInstaller
This is a minimalist example of compiling a multi-module Python program into C with Cython and building redistributable executable from it using PyInstaller

## Step 1. Design your program as a Python Package
Normally, when you design a complex Cython project, you create a `setup.py` file which translates the `.pyx` files into `.c` and then invokes a C compiler to build them into C Extensions. You might want to go one step further and even compile your plain Python files into C to obfuscate your code and make it harder for people to access. Either way, you include a Python-visible function or object to start your program, like an entry point or main function.

In this example, I've created a program to create a Mandelbrot fractal and draw it. Since I don't need to be creative here, I've called the package `my_package` and it is split into two parts, `calc.pyx` which is where the typed matrix operations that compute the fractal live, and `app.pyx` which is where the higher level drawing code lives. `app.pyx` exposes the program's entry point, the `draw_mandelbrot()` function as a Python callable.
```
|- my_package
    |- __init__.py
    |- app.pyx
    |- calc.pyx
|- setup.py
```
I created the setup script to build the package and install it:
```python
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
      zip_safe=False,            # Without these two options
      include_package_data=True, # PyInstaller may not find your C-Extensions
      packages=find_packages(),
      ext_modules=extensions)
```

## Step 2. Creating the PyInstaller script
The next step is to create a short script to configure and execute your program's entry point, so I'll refer to this as the `entrypoint script`. Depending upon how complicated your program is, this may just be two lines of code, or it may perform arbitrary computation.

```
|- my_package
    |- __init__.py
    |- app.pyx
    |- calc.pyx
|- pyinstaller
    |- my_mandelbrot.py  <<< new
|- setup.py
```

My `entrypoint script` is `my_mandelbrot.py`, which I've put in a separate directory, `pyinstaller` where all of the material for building the bundle will live.

The contents of `my_mandelbrot.py`
```python
import sys
import matplotlib

# configure the matplotlib backend to be non-graphical
matplotlib.use("agg")

from my_package import app
# parse command line arguments
try:
    cmap_name = sys.argv[1]
except IndexError:
    cmap_name = 'jet'
print("Drawing Mandelbrot with color map %r" % (cmap_name,))

# execute the program
app.draw_mandelbrot(cmap_name)
```

At this point, it's wise to ensure that you can build and install your program-as-a-package, and that you can directly run your script with Python before attempting to bundle it. After bundling, the standalone executable should do exactly the same thing.

## Step 3. Creating the PyInstaller Executable
The next step is to run PyInstaller on your `entrypoint script`, providing it with all the information about how to find your program's dependencies. 

PyInstaller, at its simplest, is just ran on a Python script and it automatically determines which modules get imported and builds up a platform-dependent executable including the Python interpreter and your script's code and its dependencies. When your script has non-code dependencies like data files or hidden dependencies like one C extension that depends upon another C extension that never gets imported from Python code, you need to tell PyInstaller to include them explicitly.

`my_package` has the latter problem, because while `my_package.__init__` imports `my_package.app`, no Python code ever imports `my_package.calc`. We can tell PyInstaller to include this module using an import hook:

```
|- my_package
    |- __init__.py
    |- app.pyx
    |- calc.pyx
|- pyinstaller
    |- pyinstaller/hook-my_package.py <<< new
    |- my_mandelbrot.py
|- setup.py
```

This file simply lists the name of a package, and if PyInstaller sees that package imported, it will automatically include the `hiddenimports` submodules in the bundle.
`pyinstaller/hook-my_package.py`
```python
hiddenimports = ["app", "calc"]
```

I run PyInstaller like so from within the `pyinstaller/` directory in my repository:

```bash
rm -rf ./build/ ./dist/
echo "Beginning build"
python -m PyInstaller -c ./my_mandelbrot.py -D \
    --exclude-module _tkinter \
    --exclude-module PyQt4 \
    --exclude-module PyQt5 \
    --exclude-module IPython \
    --workpath build --distpath dist \
    --additional-hooks-dir ./
```
Since my program uses `matplotlib`, it tries to pull in PyQt and may also include IPython. Since my program doesn't actually use these features, I explicitly exclude them. I also exclude the C bindings used for `Tkinter` since they increase the size of the produced bundle substantially. The `--aditional-hooks-dir ./` tells PyInstaller to look for import hooks in the current directory, where I've put my `hook-my_package.py` file.

The `-D` option tells PyInstaller to create a directory for the dependencies instead of embedding them into the binary executable.

If PyInstaller ran successfully, `./dist/my_mandelbrot/my_mandelbrot[.exe]` should be an executable that runs the same program that `my_mandelbrot.py` does. If you copy it and the contents of the directory it is in to another computer with the same platform, it should work without modification. It is up to you to decide how to package the bundle for distribution appropriate to your needs. 
