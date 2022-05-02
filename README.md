# Planetmint benchmarks

This repo is about testing performance of tendermint and planetmint.

## Instalation & using tendermint benchmark scrpits:

Follow instalation [guide](https://github.com/informalsystems/tm-load-test). After instalation run :
```bash
./test_square_wave.sh ; tests.sh
```


## Instalation & using planetmint benchmark:
Run in root directory following command :
```bash
python install setup.py
```
After instalation run:
```bash
planetmint-benchmar -h #to see available configuration
bigchaindb-benchmark --processes=1 --peer http://127.0.0.1:9984 send -r100 #example
```



### License
[MIT](https://choosealicense.com/licenses/agpl-3.0/)