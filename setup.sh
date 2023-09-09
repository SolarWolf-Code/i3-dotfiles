# symlinking dotfiles
mkdir -p ~/.config
rm -rf ~/.config/i3
rm -rf ~/.config/polybar
cd i3-dotfiles
shopt -s dotglob
for file in .config/*; do
  if [[ "$file" == ".git" || "$file" == "README.md" || "$file" == "setup.sh" || "$file" == ".gtkrc-2.0" ]]; then
    continue
  fi
  ln -s "$(pwd)/$file" ~/.config/"$file"
done

# adding ble.sh (autocomplete in bash)
cd 
git clone --recursive --depth 1 --shallow-submodules https://github.com/akinomyoga/ble.sh.git
make -C ble.sh install PREFIX=~/.local
echo 'source ~/.local/share/blesh/ble.sh' >> ~/.bashrc

# update bashrc
cd
mv ~/.config/.bashrc ~/.bashrc

# moving openvpn file to correct folder and start the service
cd
sed -i '/^auth-user-pass/c\auth-user-pass '"$HOME"'/ovpn/credentials.txt' ~/.config/us-slc.prod.surfshark.com_udp.ovpn

ovpn_string="/usr/bin/openvpn $HOME/.config/us-slc.prod.surfshark.com_udp.ovpn"
sed -i "s/^ExecStart=.*/ExecStart=$(echo $ovpn_string | sed 's/\//\\\//g')/" ~/.config/openvpn.service
sudo cp  ~/.config/openvpn.service /etc/systemd/system/openvpn.service
sudo systemctl enable openvpn.service

# install yay
cd
sudo pacman -S base-devel
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

yay -S --noconfirm - < ~/.config/packages.txt

# bluetooth
sudo systemctl enable bluetooth.service 
sudo systemctl start bluetooth.service

# start openvpn service
sudo systemctl start openvpn.service
