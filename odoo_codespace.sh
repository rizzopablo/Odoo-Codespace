set -e

# Update and upgrade the system
sudo apt update
sudo apt upgrade -y

echo -e "\n---- Initializing submodules ----"
git submodule update --init --recursive

echo -e "\n---- Install PostgreSQL Server ----"
sudo apt install postgresql postgresql-server-dev-all -y

echo -e "\n---- Creating the ODOO PostgreSQL User  ----"
sudo /etc/init.d/postgresql start
echo "codespace ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/codespace
sudo su - postgres -c "createuser -s odoo17" 2> /dev/null || true
sudo -u postgres psql -c "ALTER USER odoo17 PASSWORD 'odoo';" 2> /dev/null || true

echo -e "\n---- Install required dependencies ----"
sudo apt-get install -y git python3 python3-pip build-essential wget python3-dev python3-venv python3-wheel libxslt-dev libzip-dev libldap2-dev libsasl2-dev python3-setuptools node-less libjpeg-dev gdebi
sudo apt-get install -y libpq-dev python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev libffi-dev python3-psutil python3-polib python3-dateutil python3-decorator python3-lxml python3-reportlab python3-pil python3-passlib python3-werkzeug python3-psycopg2 python3-pypdf2 python3-gevent

#--------------------------------------------------
# Install Wkhtmltopdf
#--------------------------------------------------
sudo gdebi -n ./wkhtmltox_0.12.6.1-2.jammy_amd64.deb

echo -e "\n---- Setup python virtual environment ----"
sudo apt-get install -y python3-virtualenv
virtualenv odoo-venv
source "odoo-venv/bin/activate"

echo -e "\n---- Install python packages/requirements ----"
pip install wheel
pip install -r https://github.com/odoo/odoo/raw/17.0/requirements.txt
