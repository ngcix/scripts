
npx gitnexus serve --host 0.0.0.0 --port 4747
export GITNEXUS_SERVER_ADDRESS=http://localhost:4747

WIN
netsh interface portproxy add v4tov4 listenport=4747 listenaddress=0.0.0.0 connectport=4747 connectaddress=localhost