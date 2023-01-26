sudo apt update
sudo apt install curl -y
curl https://get.docker.com | sudo bash
sudo usermod -aG docker $(whoami)
