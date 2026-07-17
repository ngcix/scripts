# This is for make moonlight connect to phone

ssh -R <remote_port>:localhost:<local_port> <your_username>@<your_local_ip>
socat TCP4-LISTEN:<local_port>,fork,reuseaddr TCP4:<public_relay_ip>:<public_port>

# Termux
```sh 2
ssh \
-R 47984:localhost:57984 \
-R 47989:localhost:57989 \
-R 48010:localhost:58010 \
-R 57999:localhost:57999 \
-R 58000:localhost:58000 \
-R 58001:localhost:58001 \
ntc@localhost
```

# In Userland
```sh 1

#!/bin/bash
socat TCP-LISTEN:57984,fork,reuseaddr TCP:mcnc.vinaddns.com:47984 &
socat TCP-LISTEN:57989,fork,reuseaddr TCP:mcnc.vinaddns.com:47989 &
socat TCP-LISTEN:58010,fork,reuseaddr TCP:mcnc.vinaddns.com:48010 &
socat TCP-LISTEN:57999,fork,reuseaddr UDP:mcnc.vinaddns.com:47999 &
socat TCP-LISTEN:58000,fork,reuseaddr UDP:mcnc.vinaddns.com:48000 &
socat TCP-LISTEN:58001,fork,reuseaddr UDP:mcnc.vinaddns.com:48010 &
wait
```

```sh

socat TCP-LISTEN:47984,fork,reuseaddr TCP:100.99.1.1:47984 &
socat TCP-LISTEN:47989,fork,reuseaddr TCP:100.99.1.1:47989 &
socat TCP-LISTEN:48010,fork,reuseaddr TCP:100.99.1.1:48010 &
socat TCP-LISTEN:47990,fork,reuseaddr TCP:100.99.1.1:47990 &

socat UDP-LISTEN:47998,fork,reuseaddr UDP:100.99.1.1:47998 &
socat UDP-LISTEN:47999,fork,reuseaddr UDP:100.99.1.1:47999 &
socat UDP-LISTEN:48000,fork,reuseaddr UDP:100.99.1.1:48000 &
socat UDP-LISTEN:48010,fork,reuseaddr UDP:100.99.1.1:48010 &



```

# In the PC
```sh
#!/bin/bash
socat UDP-LISTEN:47999,fork,reuseaddr TCP:localhost:57999 &
socat UDP-LISTEN:48000,fork,reuseaddr TCP:localhost:58000 &
socat UDP-LISTEN:48010,fork,reuseaddr TCP:localhost:58001 &
wait
```

# WSL
sudo apt install vainfo libva-drm2 libva-x11-2 libva-glx2
sudo apt install vulkan-tools libvulkan1


socat tcp-listen:5555,reuseaddr,fork tcp:localhost:5555
