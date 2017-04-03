cd /opt/

#HTTPSCREENSHOT:
git clone https://github.com/breenmachine/httpscreenshot.git
cd /httpscreenshot/
./install-dependencies.sh

#NOSQLMAP:
git clone https://github.com/tcstool/NoSQLMap.git

#CMSMAP:
git clone https://github.com/Dionach/CMSmap.git

#RANGER:
git clone https://github.com/ranger/ranger.git
cd ./ranger/
sudo make install

#CONKY:
sudo apt-get install conky-all
