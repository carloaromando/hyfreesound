from setuptools import setup, find_packages

setup(
    name='hyfreesound',
    version='0.1',
    packages=find_packages(),
    author='c_aromando',
    author_email='carlo.aromando@gmail.com',
    url='https://github.com/carloaromando/hyfreesound',
    install_requires=[
        'hy==0.15.0',
        'requests==2.21.0'
    ],
    package_data={'hyfreesound': ['*.hy']},
    license='BSD-new'
)
