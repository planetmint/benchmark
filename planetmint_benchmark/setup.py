from setuptools import setup, find_packages

setup(
    name='planetmint_benchmark',
    version='0.2.0',
    description='Command Line Interface to push transactions to BigchainDB',
    author='BigchainDB devs',
    packages=find_packages(),
    install_requires=[
        'bigchaindb-driver~=0.6.2',
        'coloredlogs~=7.3.0',
        'websocket-client',
        'logstats~=0.3.0',
        'requests~=2.20.0',
        'cachetools~=2.1.0',
        'websockets>=9.1.0',
        'aiohttp>=3.7.4',
        'datetime'
    ],
    entry_points={
        'console_scripts': [
            'planetmint-benchmark=planetmint_benchmark.commands:main',
            'planetmint-blaster=planetmint_benchmark.async.__init__:main',
        ],
    },
)
