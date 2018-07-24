# Docker-WireCloud

This a docker image based on the original [fiware/wirecloud:1.1](https://github.com/Wirecloud/docker-wirecloud/tree/master/1.1).
The major difference is, that this image can also be configured to use a Postgres
database in addition to squlite.

## How to use this image with Postgres

Firstly you need to have a postgres database up and runnung:

`docker run -d --name postgres postgres`

In order to change the database configuration you need a volume that gets bound
to the wirecloud working directory in the container:

```
docker volume create --driver local \
    --opt type=none \
    --opt device=$configVolumePath \
    --opt o=bind \
    config_vol
```

Where `$configVolumePath` is an existing folder on your host machine.

Now you are good to start the wirecloud container:

```
docker run -d --name wirecloud -p 80:80 \
    -v config_vol:/opt/wirecloud_instance \
    --link "postgres:postgres" \
    fhjima/docker-wirecloud
```

This will start the standalone configuration of WireCloud. You can change this
by opening the `wirecloud_instance/settings.py` in your mounted volume and change the database
configuration:

```python

...

DATABASES = {
      'default': {
             'ENGINE': 'django.db.backends.postgresql_psycopg2',
             'NAME': 'postgres',
             'USER': 'postgres',
             'PASSWORD': 'postgres',
             'HOST': 'postgres',
             'PORT': '5432',
     }
}

...

```

Now you are good to restart you container:

`docker restart wirecloud`

Now you are almost done. All that is left is probably setting a new superuser:

`docker exec -it wirecloud su wirecloud -c "python manage.py createsuperuser"`
