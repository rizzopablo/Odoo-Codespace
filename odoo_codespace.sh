# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

echo -e "\n---- Initializing submodules ----"
git submodule init && git submodule update --depth 1

echo -e "\n---- Install PostgreSQL Server ----"
sudo apt install postgresql postgresql-server-dev-all -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo /etc/init.d/postgresql start
echo "codespace ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/codespace
sudo su - postgres -c "createuser -s odoo17" 2> /dev/null || true
sudo -u postgres psql -c "ALTER USER odoo17 PASSWORD 'odoo';" 2> /dev/null || true

echo -e "\n---- Install required dependencies ----"
cd odoo
sudo ./setup/debinstall.sh
cd ..
sudo apt install -y build-essential libssl-dev libsasl2-dev libldap2-dev python3-dev pkg-config

# #--------------------------------------------------
# # Install Wkhtmltopdf
# #--------------------------------------------------
# sudo apt install -y ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb

echo -e "\n---- Setup python virtual environment ----"
virtualenv odoo-venv
source "odoo-venv/bin/activate"

# echo -e "\n---- Install python packages/requirements ----"
pip install --upgrade --no-input pip
pip install --no-input wheel
pip install --no-input -r https://github.com/odoo/odoo/raw/19.0/requirements.txt
