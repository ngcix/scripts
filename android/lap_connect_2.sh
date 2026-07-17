#!/data/data/com.termux/files/usr/bin/bash

autossh -M 0 -f -N \
 -R 2222:localhost:2222 \
 -R 3333:localhost:3333 \
 -R 5555:localhost:5555 \
 -R 8888:localhost:8888 \
 -L 9998:localhost:9998 \
 -R 22222:localhost:22222 \
 ntc@localhost

autossh -M 0 -f -N \
 -R 2222:localhost:2222 \
 -R 3333:localhost:3333 \
 -R 5555:localhost:5555 \
 -R 8888:localhost:8888 \
 -L 9998:localhost:9998 \
 -R 22222:localhost:22222 \
 ntc@localhost
