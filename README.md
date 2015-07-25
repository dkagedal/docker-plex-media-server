Dockerized [Plex Media Server](https://plex.tv/).

Usage
-----

You should provide a least two mount points accessibly by user #**1030** (`plex` inside the container):

  * `/config`: To somewhere to hold your Plex configuration (can be a data-only container). This will include all media listing, posters, collections and playlists you've setup...
  * Mount one or more of your media files (videos, audio, images...) as `/media` or some other mount location.

Example:

    $ mkdir ~/plex-config
    $ chown 1030:1030 -R ~/plex-config
    $ docker run -d --restart=always -v ~/plex-config:/config -v ~/Movies:/media -p 32400:32400 wernight/plex-media-server

The `--restart=always` is optional, it'll for example allow auto-start on boot.

If you want Avahi broadcast to work, add `--net=host` but this will be more insecure. Without it you may also not see the `Server` tab unless the server is logged in, see troubleshooting section below.

Once done, wait about a minute and open `http://localhost:32400/web` in your browser.


Features
--------

  * Built using official Docker [Ubuntu](https://registry.hub.docker.com/_/ubuntu/) and official [Plex download](https://plex.tv/downloads).
  * Runs Plex as `plex` user (not root as [Docker's Containers don't contain](http://www.projectatomic.io/blog/2014/09/yet-another-reason-containers-don-t-contain-kernel-keyrings/)).
  * Avoids [PID 1 / zombie reap problem](https://blog.phusion.nl/2015/01/20/docker-and-the-pid-1-zombie-reaping-problem/) (if plex or one of its subprocesses dies) by running directly plex.
  * Supports Plex upgrade system.


Environment Variables
---------------------

You can change some settings by setting environement variables:

  * `PLEX_MEDIA_SERVER_MAX_STACK_SIZE` ulimit stack size (default: 3000).
  * `ENV PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS` the number of plugins that can run at the same time (default: 6).


Troubleshooting
---------------

  * I have to accept EULA each time?!
      * Did you forget to mount `/config` directory? Check also that it's writable by user `797`.
  * Cannot see [**Server** tab](http://localhost:32400/web/index.html#!/settings/server) from settings!
      * Try running once with `--net=host`. You may allow more IPs without being logged in by then going to Plex Settings > Server > Network > List of networks that are allowed without auth; or edit `your_config_location/Plex Media Server/Preferences.xml` and add `allowedNetworks="192.168.1.0/255.255.255.0"` attribute the `<Preferences …>` node or what ever your local range is.
  * Why do I have a random server name each time?
      * Either set a friendly name undex Plex Settings > Server > General; or start with `-h some-name`.


Backup
------

Honestly I wish there was a more official documentation for this. What you really need to back-up (adapt `~/plex-config` to
your `/config` mounting point):

  * Your media obviously
  * `~/plex-config/Plex Media Server/Media/`
  * `~/plex-config/Plex Media Server/Metadata/`
  * `~/plex-config/Plex Media Server/Plug-in Support/Databases/`

In practice, you may want to be safer and back-up everything except may be `~/plex-config/Plex Media Server/Cache/`
which is pretty large and you can really just skip it. It'll be rebuild with the thumbnails, etc. as you had them.
But don't take my word for it, it's really easy for you to check.


Feedbacks
---------

Having more issues? [Report a bug on GitHub](https://github.com/wernight/docker-plex-media-server/issues).
