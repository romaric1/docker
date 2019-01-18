#####APACHE PHP ##########
### Image de base ###
FROM debian:jessie
### Installation des paquets ###
RUN apt-get update && apt-get install -y apt-transport-https wget
RUN echo "deb https://packages.sury.org/php/ jessie main" >> /etc/apt/sources.list
RUN wget https://packages.sury.org/php/apt.gpg
RUN apt-key add apt.gpg
RUN rm apt.gpg
RUN apt-get update && apt-get -y install \
php7.1-cli \
php7.1-common \
php7.1-curl \
php7.1-dev \
php7.1-gd  \
php7.1-intl \
php7.1-mcrypt \
php7.1-mysql \
php7.1-odbc \
php7.1-opcache \
php7.1-pgsql \
php7.1-readline \
php7.1-sqlite3 \
php7.1-xml \
php7.1-xsl \
php7.1-zip \
php \
libapache2-mod-php \
apache2-mpm-itk \
ssmtp \
rsyslog
### Configuration d'Apache ###
RUN rm /var/www/html/index.html && \
mkdir /etc/apache2/ssl
WORKDIR /etc/apache2/ssl
### Configuration du certificat auto-signé
RUN openssl genrsa -out apache.key 1024 && \
openssl req -nodes -new -x509 -days 365 -key apache.key -out apache.crt -subj "/C=FR/ST=Aquitaine/L=BDX/O=LPL/OU=HOSTING/CN=docker-localhost"
##On ajoute le info.php et le script apache.sh
COPY services.sh /
COPY status.conf /etc/apache2/mods-available/
COPY 000-default.conf /etc/apache2/sites-available/
COPY default-ssl.conf /etc/apache2/sites-available/
COPY php.ini /etc/php/7.0/cli/
COPY ssmtp.conf /etc/ssmtp/
COPY info.php /var/www/
##Configuration du module mpm-itk
RUN useradd lpl -s /bin/bash -d /home/lpl -m
##Activation des modules d'Apache
RUN a2enmod ssl status rewrite expires
##Acivation des sites
RUN a2ensite  default-ssl.conf
## ON partage le repertoire .../html  du conteneur
VOLUME ["[/var/www/html]"]
##On lance le service apache2
CMD ["bash","/services.sh"]
