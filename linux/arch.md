# WSL

## temp set proxy
tee /etc/environment << 'EOF'
http_proxy="http://107.98.150.183:3333"
https_proxy="http://107.98.150.183:3333"
HTTP_PROXY="http://107.98.150.183:3333"
HTTPS_PROXY="http://107.98.150.183:3333"
no_proxy="localhost,127.0.0.1,localaddress,.samsung.net,.secsso.net,ipaas-mcp.sec.samsung.net,.samsung.com,.samsungif.com"
NO_PROXY="localhost,127.0.0.1,localaddress,.samsung.net,.secsso.net,ipaas-mcp.sec.samsung.net,.samsung.com,.samsungif.com"
EOF

source /etc/environment

## Ignore ssl with http proxy
sed -i 's|#XferCommand = /usr/bin/curl|XferCommand = /usr/bin/curl -k|' /etc/pacman.conf

## run pacman
pacman -Sy fish micro sudo 

## add user
useradd -m -G wheel nc
passwd nc
micro /etc/sudoers

```diff
--# %wheel ALL=(ALL:ALL) ALL
++%wheel ALL=(ALL:ALL) ALL
```

## set fish as default shell
chsh -s /usr/bin/fish # for root
chsh -s /usr/bin/fish nc

## update
su nc
sudo pacman -Syu

## proxy for fish in config file
set -gx http_proxy http://107.98.150.183:3333
set -gx https_proxy http://107.98.150.183:3333
set -gx all_proxy http://107.98.150.183:3333


## GPG proxy
mkdir -p ~/.gnupg
echo "http-proxy http://107.98.150.183:3333" >> ~/.gnupg/dirmngr.conf
gpgconf --kill dirmngr

## Custom pacman downloader
micro /etc/pacman.conf

```diff
--XferCommand = /usr/bin/curl -k -L -C - -f -o %o %u
++#XferCommand = /usr/bin/curl -k -L -C - -f -o %o %u


--#Color
--NoProgressBar
++Color
++#NoProgressBar
++ILoveCandy
```

## Locale
sudo locale-gen en_US.UTF-8
sudo   -i '/^#en_US.UTF-8 UTF-8/s/^#//' /etc/locale.gen
sudo locale-gen

echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "LC_ALL=en_US.UTF-8" >> /etc/locale.conf




## AUR yay
<!-- sudo pacman -Syu ca-certificates ca-certificates-utils -->
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

## Turbo VNC
yay -S turbovnc

## Config fish
```
if status is-interactive
    set -U fish_greeting ""
    set -gx http_proxy http://107.98.150.183:3333
    set -gx https_proxy http://107.98.150.183:3333
    set -gx all_proxy http://107.98.150.183:3333
    set -gx no_proxy "*.samsung.net,*.secsso.net,ipaas-mcp.sec.samsung.net,*.samsung.com,*.samsungif.com,107.0.0.0/8"

    set -gx HTTP_PROXY $http_proxy
    set -gx HTTPS_PROXY $https_proxy
    set -gx ALL_PROXY $all_proxy
    set -gx NO_PROXY $no_proxy

    set -gx DONT_PROMPT_WSL_INSTALL 1
```

## Fix file manager network
sudo pacman -S gvfs


## P4
yay -S p4
yay -S p4v

sudo pacman -S --needed nss libxi libxrender libxrandr libxcursor libxkbfile
sudo pacman -S --needed mesa lib32-mesa vulkan-swrast


# Fix GUI WSLG

1. must have prefix
dbus-run-session nautilus

2. config fish:
```sh
if status is-interactive
    set -U fish_greeting ""
    set -gx http_proxy http://107.98.150.183:3333
    set -gx https_proxy http://107.98.150.183:3333
    set -gx all_proxy http://107.98.150.183:3333
    set -gx no_proxy "*.samsung.net,*.secsso.net,ipaas-mcp.sec.samsung.net,*.samsung.com,*.samsungif.com,107.0.0.0/8"

    set -gx HTTP_PROXY $http_proxy
    set -gx HTTPS_PROXY $https_proxy
    set -gx ALL_PROXY $all_proxy
    set -gx NO_PROXY $no_proxy

    set -gx DONT_PROMPT_WSL_INSTALL 1

    # GUI
    set -gx GALLIUM_DRIVER zink
    set -gx MESA_LOADER_DRIVER_OVERRIDE d3d12
    
    set -gx GDK_SCALE 1
    set -gx GDK_DPI_SCALE 1
    set -gx XDG_CURRENT_DESKTOP GNOME
    set -gx XDG_RUNTIME_DIR /run/user/(id -u)
        
    set -gx GDK_BACKEND x11
    set -gx XDG_SESSION_TYPE x11

    set -gx MESA_LOADER_DRIVER_OVERRIDE swrast
    set -gx GALLIUM_DRIVER llvmpipe
    set -gx GVFS_DISABLE_FUSE 1
    set -gx GIO_USE_VFS local

    # alias nautilus="dbus-run-session nautilus"
    # alias gnome-control-center="dbus-run-session gnome-control-center"
    # alias gnome-tweaks="dbus-run-session gnome-tweaks"
end

alias codium='/mnt/d/HQ_APKFiles/Programs/VSCodium/bin/codium'

```
