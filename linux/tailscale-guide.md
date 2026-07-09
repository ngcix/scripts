# Setup,  nen chay lan dau khi mo VPS, chi can chay 1 lan
apt update
apt upgrade -y


# Cai tailscale 
https://tailscale.com/kb/1039/install-ubuntu-2004

```sh
curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null

curl -fsSL https://pkgs.tailscale.com/stable/ubuntu/focal.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list

sudo apt-get update
sudo apt-get install tailscale -y
```

# Neu bi loi: unable to resolve host TanVDRemote: Name or service not known

cat /etc/hosts
127.0.0.1       localhost
127.0.0.1 TanVD_Remote

- Loi nam o dau "_", xoa di la duoc

#
sudo iptables -t nat -A PREROUTING -p udp --dport 9000 -j DNAT --to-destination 100.99.1.1:9000
sudo iptables -t nat -A PREROUTING -p tcp --dport 9000 -j DNAT --to-destination 100.99.1.1:9000


# Add proxy to tailscale
sudo vim /etc/default/tailscaled

HTTPS_PROXY="http://localhost:3333"
HTTP_PROXY="http://localhost:3333"

Then restart

sudo systemctl restart tailscaled