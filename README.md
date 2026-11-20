# Live Custom Server (versão White)

Servidor baseado no The Forgotten Server (3777), já compilado para Windows x64.

## Rodar o servidor (Windows)

1. Baixe ou clone este repositório.
2. Copie o banco limpo para a raiz:
   ```
   copy schemas\theforgottenserver.s3db theforgottenserver.s3db
   ```
3. Copie a configuração de exemplo:
   ```
   copy config.lua.dist config.lua
   ```
4. Abra o `config.lua` e ajuste:
   ```lua
   sqlType = "sqlite"
   sqlFile = "theforgottenserver.s3db"
   ip = "127.0.0.1"   -- seu IP, se for jogar em rede
   ```
5. Execute `theforgottenserver.exe`.

As DLLs necessárias já estão na raiz. Não é preciso instalar nada.

### Conta de teste

O banco limpo traz uma conta padrão: login `1`, senha `1`.
Ela tem acesso total (god). **Troque ou apague antes de abrir o servidor para outras pessoas.**

### Banco do zero (opcional)

Para recriar o banco a partir do schema, com o `sqlite3` instalado:
```
sqlite3 theforgottenserver.s3db < schemas\sqlite.sql
```
Para MySQL, use `schemas\mysql.sql` e configure `sqlType = "mysql"` no `config.lua`.

## Compilar

Para compilar no Windows (MSYS2 UCRT64 + Ninja), edite o caminho `MSYS` em `compilar.bat` e execute:
```
compilar.bat
```
O exe novo é copiado para a raiz e o anterior é salvo como `.bak`.


---

## Useful links
### Binaries
- Windows x32: https://github.com/Fir3element/binaries/raw/master/x32-windows.zip
- Windows x64: https://github.com/Fir3element/binaries/raw/master/x64-windows.zip

### Source
- https://github.com/Fir3element/3777/archive/master.zip

## Libraries for Visual Studio 2022 (using vcpkg)

- x32:
```
.\vcpkg install luajit sqlite3 libmariadb libxml2 gmp boost-filesystem boost-regex boost-thread boost-asio boost-foreach boost-any openssl
```

- x64:
```
.\vcpkg install --triplet x64-windows luajit sqlite3 libmariadb libxml2 gmp boost-filesystem boost-regex boost-thread boost-asio
```

## Build instruction for Ubuntu

```
sudo apt-get update
```

```
sudo apt-get install --no-install-recommends -y git autoconf automake pkg-config build-essential cmake liblua5.1-0-dev libsqlite3-dev libmysqlclient-dev libxml2-dev libgmp3-dev libboost-filesystem-dev libboost-regex-dev libboost-thread-dev
```

```
git clone https://github.com/Fir3element/3777.git
```

```
cd /3777-master
```

```
mkdir build
```

```
cd build
```

```
cmake ..
```

```
make -j$(grep processor /proc/cpuinfo | wc -l)
```
