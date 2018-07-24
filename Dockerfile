FROM python:2-stretch

MAINTAINER WireCloud Team <wirecloud@conwet.com>

# Install apache2, social-auth and create a wirecloud user
RUN apt-get -y update && \
    apt install -y libmemcached-dev ca-certificates && \
    apt-get install -y apache2 libapache2-mod-wsgi && \
    pip install --no-cache-dir social-auth-app-django "gunicorn==19.3.0" "psycopg2==2.6" pylibmc && \
    adduser --system --group --shell /bin/bash wirecloud && \
    rm -rf /var/lib/apt/lists/*

COPY ["apache-config.conf", "/etc/apache2/sites-enabled/000-default.conf"]

WORKDIR /opt

# Install WireCloud & dependencies
RUN pip install --no-cache-dir "wirecloud<1.2"

RUN wirecloud-admin startproject wirecloud_instance --quick-start && \
    chown -R wirecloud:wirecloud wirecloud_instance

WORKDIR /opt/wirecloud_instance
RUN sed -i "s/SECRET_KEY = '[^']\+'/SECRET_KEY = 'TOCHANGE_SECRET_KEY'/g" wirecloud_instance/settings.py

# The volume must be created after running the wirecloud-admin command
VOLUME /opt/wirecloud_instance
VOLUME /etc/apache2
WORKDIR /opt/wirecloud_instance

EXPOSE 80

COPY ./docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh"]
