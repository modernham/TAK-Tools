#!/bin/bash
color() {
    STARTCOLOR="\e[$2";
    ENDCOLOR="\e[0m";
    export "$1"="$STARTCOLOR%b$ENDCOLOR"
}
color info 96m
color success 92m
color warning 93m
color danger 91m
export PATH=$PATH:/sbin
printf $warning "\nPlease enter your username\n";
read usr
if [ $UID -eq 0 ]; then
  export PATH=$PATH:/sbin
  apt-get update -y
  apt-get install sudo -y
  cp takinstall.sh /home/$usr/
  chmod +x /home/$usr/takinstall.sh
  chmod 777 /home/$usr/takinstall.sh
  sh -c "echo \"takusr ALL=(ALL) NOPASSWD: ALL\" >> /etc/sudoers"
  printf $success "User ${usr} added to sudoers\n";
  printf $info "Adding docker group\n";
  groupadd docker
  usermod -aG docker ${usr}
  printf $success "User ${usr} added to Docker group\n";
  printf $success "Switching to: ${usr}\n";
  printf $info "\nInstalling needed tools, and enabling SSH\n";
  sudo apt install openssh-server git unzip zip net-tools python3 -y
  sudo service ssh start
  sudo service ssh enable
  apt-get install net-tools -y
  sudo apt -y install apt-transport-https ca-certificates curl gnupg2 software-properties-common
  printf $info "Adding path for ifconfig needed later...\n";
  printf $info "Installing Docker\n";
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
  printf $success "Docker Installed\n";
  sudo systemctl enable --now docker
  printf $success "Docker Enabled!\n";
  printf $info "Opening Ports, some of these will fail, it is okay\n";
  sudo ufw allow 5432/tcp
  sudo ufw allow 80/tcp
  sudo ufw allow 8089/tcp
  sudo ufw allow 8443/tcp
  sudo ufw allow 8446/tcp
  sudo ufw allow 9000/tcp
  sudo ufw allow 9001/tcp
  sudo iptables -I INPUT -p tcp --dport 5432 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 8089 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 8443 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 8446 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 9000 -j ACCEPT
  sudo iptables -I INPUT -p tcp --dport 9001 -j ACCEPT
  printf $success "TAK Server Ports opened\n";
  printf $info "Leaving root, and finishing install with ${usr}\n";
  printf $warning "You will be asked for your username again\n";
  cd /home/$usr
  exec su "$usr" "$0" -- "$@"
fi
printf $info "\nStarting user install portion\n";
export PATH=$PATH:/sbin
printf $info "\nCloning the TAK Server Docker Setup Script\n"
git clone https://github.com/Cloud-RF/tak-server.git
cd tak-server
ip4=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
printf $danger "\nPlease transfer your TAKSERVER-DOCKER-X.X-RELEASE ZIP file to the newly made tak-server folder \n"
printf $info "You can do this from windows by using using the following command in a cmd/powershell in the same folder as your ZIP \n"
printf $warning "scp takserver-docker-4.9-RELEASE-46.zip ${usr}@${ip4}:~/tak-server\n"
printf $danger "You will get validation errors on the zip, its safe to ignore them\n";
printf $info "\nPress enter to continue ONLY when you have the zip in /home/${usr}/tak-server\n"
read ans
sudo chmod +x scripts/setup.sh
./scripts/setup.sh
printf $success "\nCompleted base install, find login info above.\n"
printf $info "\nCopying your admin and server certs to /home/${usr}/certs \n"
mkdir /home/${usr}/certs
cp /home/${usr}/tak-server/tak/certs/files/* /home/${usr}/certs
printf $info "\nChainging permissiosn on coppied cert files.\n"
sudo chmod 777 /home/${usr}/certs/*
printf $success "\nYou can now obtain your certs from /home/${usr}/certs \n"
printf $info "\nDo this easily from windows by issuing this command from the folder you'd like the certs in: \n"
printf $warning "scp ${usr}@${ip4}:~/certs/* . \n"
printf $info "\nYou may also download them from your webrowser at: \n"
printf $warning "http://${ip4}/ \n"
printf $danger "Press CTRL+C to close this script and the webserver\n";
sudo chmod 777 -R /home/${usr}/certs
sudo chmod -R 777 /home/${usr}/certs
python3 -m http.server 80 -d /home/${usr}/certs
