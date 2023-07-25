from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
    Extension(
        "lpcynet",
        ["lpcynet.pyx"],
        libraries=["lpcnet"],
        library_dirs=["./lpcnet"],
        runtime_library_dirs=["$ORIGIN/lpcnet"],
    )
]

for e in ext_modules:
    e.cython_directives = {"language_level": "3"}

setup(name="lpcynet", cmdclass={"build_ext": build_ext}, ext_modules=ext_modules)
