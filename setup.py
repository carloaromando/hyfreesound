from setuptools import setup

HYSRC = ['**.hy']

setup(
    name='hyfreesound',
    version='0.1',
    packages=['hyfreesound'],
    author='c_aromando',
    author_email='carlo.aromando@gmail.com',
    url='https://github.com/carloaromando/hyfreesound',
    install_requires=[
        'hy==0.15.0',
        'requests==2.21.0'
    ],
    package_data={'hyfreesound': HYSRC},
    license='BSD-new'
)
