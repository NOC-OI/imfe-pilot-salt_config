# Salt scripts to configure VMs

This repository contains a set of Salt scripts to configure the virtual machines. Please make all changes to the server by editing this repository.
Note that changes are NOT automatically applied to the system.

## Architecture

These Salt rules are designed for deployment on a set of virtual machines with Intel/AMD architecture, running Ubuntu 22.04. The setup assumes the presence of one gateway VM with an external IP, and Salt is deployed in local masterless mode.

We have currently tested this architecture on the following platforms:

- Oracle Cloud, utilizing Intel processors and running Ubuntu 22.04.
- JASMIN, also using Intel processors and running Ubuntu 22.04.

### Hostnames

The hosts are assigned random IP addresses by the provider. The hosts file is populated with user-friendly names for these hosts based on the `hosts/hosts.sls` file. The hostnames currently allocated are as follows:

* **gateway**: This is the only one with a public IP address.
* **web**: A VM designed for deploying public websites.
* **build**: A VM for executing CI/CD tasks, such as GitLab runners.

### Accessing the Nodes via SSH

There are two methods for connecting to the nodes:

A) Connect to the gateway and then to the desired node:

1. Execute `ssh -A <username>@<gateway external IP>`. This command adds your SSH key to the ssh-agent on the gateway, enabling you to use your key for accessing the nodes.
2. To connect to a worker node, use the command `ssh nodename`, for example, `ssh web`.

B) Connect to the node through the gateway:

1. Run `ssh -J <username>@<gateway external IP> -X ssh nodename`. This allows you to pass your SSH key directly to the node and establish a connection.

### Web proxying

The gateway runs a proxying web server and redirects different URLs to different nodes. This is controlled by pillar/webserver.sls and salt/apache/files/default-ssl.conf. The firewall on the worker nodes has port 8080 open, to open other ports edit pillar/firewall/init.sls. 

#### Rewriting URLs

The gateway will redirect requests for a subdirectory e.g. https://gateway/web to one of the nodes e.g. http://web:8080/. The application on the node will need to expect all requests will start with /web instead of /. 

#### SSL 

The gateway provides SSL encryption, even if the connection to the node isn't encrypted. Currently it just uses an self-signed certificate that will generate warnings in the browser.

### Swapspace and /var/lib/docker

Some VMs (currently build and web) were running out of disk space due to lots of docker images. These both have an extra volume mounted to /var/lib/docker. They were also running out of RAM, so have a swapfile in /var/lib/docker/swapfile. 

## Deploying Salt for the First Time

To deploy Salt for the first time, you need to configure it initially for the gateway VM. Please follow the steps below:

1. Create the VM on the cloud provider:
   - JASMIN Cloud Portal - [https://cloud.jasmin.ac.uk](https://cloud.jasmin.ac.uk)
   - Oracle Cloud - [https://cloud.oracle.com](https://cloud.oracle.com)

2. Before applying the Salt configuration to the VMs, ensure that you update the `salt_config` repository with changes related to your project. Please push your changes to the `salt_config` repository as a new branch (never push to master). You need to edit the following files in the repository:

   - a) `pillar/host.sls`: Edit the IP address of the gateway with the public IP address provided by the Cloud Provider. If you already know the private IP addresses of the other VMs, you can update them in this file.
   - b) `salt/certbot/certbot.cls`: Comment the line containing the `renew` command and uncomment the line containing the `--domains` content. If you already know the domain names for your public websites, you can also update them in this file. However, even with these changes, you may need to run this command manually in the future.
   - c) `pillar/webserver.sls`: If you already have the domain names for your websites, you can update them here. Please use the frontend web server as an example; it has `apache_frontend_virtualserver_config`, `apache_frontend_ssl_virtualserver_config`, `frontend_webserver_ip`, `frontend_webserver_port`, and `frontend-hostname`. You'll need to create equivalents of these for your new web service.
   - d) Create an Apache configuration for the non-SSL and SSL versions of the new web host. These configurations need to be created in `salt/apache/files`. They will be deployed to `/etc/apache2/sites-enabled`. Again, use the frontend configuration as an example; it has `frontend.conf`, which redirects non-SSL traffic to the SSL (https) webpage. Copy this and change the `servername` item to match the pillar entry you created in step **C**. The file `frontend-ssl.conf` is the one that proxies to the Docker container. This file needs to know the hostname/IP address running the container and the port number. These should be specified through the pillar.
   - e) Edit the Apache deployment file to enable your virtual server. Edit `salt/apache/apache.sls` and copy the entries for "create frontend virtualserver" and "create frontend SSL virtualserver," adjusting them to match the name of the pillar variable pointing to your new virtual server config. The `source://` address also needs changing to match the names of the files you created in step **D**. This information doesn't come from a pillar, but this is the only place where it's referenced.
   - f) Open the firewall port on the web VM (or whichever VM is running this) for the Docker container by editing `pillar/firewall/init.sls`.

3. Log in to the gateway with SSH using the root account.
4. Copy the `install.sh` script to the VM. You may need to change the user in the `git clone` command within this script.
5. Run the `install.sh` script (`bash ./install.sh` or `chmod +x install.sh; ./install.sh`). It will clone this repository to the `/srv/salt/` folder.
6. If the VM is using swap (check for the use of `docker.swapspace` in `salt/top.sls`), make sure that `/var/lib/docker` is mounted, or there is more than 8GB of free disk space before running Salt.
7. Apply the Salt state with `salt-call --local state.apply`.
8. If you receive warnings or errors related to SSL encryption ("certbot"), you may need to create/update the SSL certificates yourself. Please refer to the section "DNS and SSL" for more information on configuring DNS and SSL for your domains.

### Configuration of DNS and SSL

To use custom domains for your project (instead of your IP address), you need to configure the DNS entries with your domain provider. The steps to follow may vary depending on the DNS provider:

- **NOC DNS entry (e.g., 'noc.ac.uk'):**

1. Contact NOC IT via email (servicedesk@noc.ac.uk) and request them to create/update the domain and redirect it to the public IP address of your gateway VM.
2. Log in to your gateway VM and run the following command. You need to change the `<your-email-address>` and `<domain-name>`:

   ```bash
   certbot --apache -m <your-email-address> --agree-tos -n --domains <domain-name>
   ```

3. You may need to stop the apache service first by running `service apache2 stop`.

4. If the certbot command did not work, you may have to follow the options below:

- Add `--standalone` flag to the certbot command

- Run the following command instead `certbot certonly --manual --preferred-challenges dns`. This command will prompt you for your email address and the domain name that NOC IT sent to you. The last step will be to verify that you are the owner of the domain. In this case, it will ask you to add a DNS entry on your domain with type TXT. You need to provide this information to NOC IT for configuring the SSL encryption.

5. If everything proceeds smoothly, your DNS is already configured, and you have SSL encryption for your domain. If not, you need to check with NOC IT to ensure that they have included the TXT entry in the DNS correctly.

6. If you want to use a new domain for other websites within the same Salt configuration, you need to request NOC IT to create these domains. These domains will use the same IP address.

7. To add SSL encryption to the new domain, run the following command. Please make sure to replace "<your-first-domain-name>" with the domain name you used for configuring the SSL and "<your-new-hostname>" with your new domain name:

   ```bash
   certbot certonly --cert-name <your-first-domain-name> --apache -d <your-new-hostname>
   ```

8. In this case, you do not need to configure the TXT DNS entry for your new domain.

9. After all the configuration, you may need to reload the Apache configuration with:

   ```bash
   service apache2 reload
   ```

- **Other Domain Provider:**

1. If you want to deploy public websites with 'co.uk', there are some places that allow you to buy free domains for one year. Please check [https://www.names.co.uk/](https://www.names.co.uk/) and [https://www.lcn.com/](https://www.lcn.com/) for more information.
2. If you create your domain on one of these platforms, you will follow the same steps as for an NOC DNS entry. However, you will be responsible for updating the IP address and maybe the TXT DNS entry on the domain provider's pages.

### Deploying to another VM

To deploy to a new VM:

1. Create the VM in the Cloud provider. This new VM will not have a public IP address and it will be connect to the gateway VM by sharing the same VCN.

2. Before applying the Salt configuration to the VMs, ensure that you update the `salt_config` repository with changes related to your project. Please push your changes to the `salt_config` repository as a new branch (never push to master). You need to edit the following file in the repository:

   - a) `pillar/host.sls`: Edit the IP address of the private IP address of your new VM.

3. Log in to your new VM with SSH using your root account. Please follow the steps described in [Accessing the Nodes via SSH](###-Accessing the Nodes via SSH)

4. Copy the install.sh script to the VM. Maybe you need to change the user on the "git clone" command on this script.

5. Run the install.sh script (`bash ./install.sh` or `chmod +x install.sh ; ./install.sh`). It will clone the this repository to the /srv/salt/ folder.
6. If the VM is using swap (check for use of docker.swapspace in salt/top.sls), make sure /var/lib/docker is mounted or there is more than 8GB of free disk space before running salt. 
7. Apply the salt state `salt-call --local state.apply`
8. As you changed things in salt, you need to update the configuration on the gateway VM as well. Please follow the steps of the next section.

## Changing things in Salt

If you change something in Salt do the following to deploy the change:

1. Push your changes to this git repository
2. Pull the changes on the node in /srv/salt 
3. Run `salt-call --local state.apply` to apply them.
4. If you have some warnings related to the IP address of new VMs that you update the IP, you may need to edit the IP entries on the file `/etc/hosts`. You have the update the IP address of your new VMs on this file.

Salt splits files between the "pillar" which is configuration information and variables and "salt" which contains the actual rules which do the work using the pillar data. Pillar variables can be placed into configuration files using the syntax `{{pillar['variable_name']}}`. Salt also has "grains" which are system variables such as the hostname or OS version, you can see a list of these by running `salt-call --local grains.ls` or the value of one with `salt-call --local grains.get <grain name>`. 

### Adding a new user 

Create a file in `salt/user` directory copying one of the existing users. Change both the rule names to include the new users name and the name field in the user.present and ssh_auth.present sections and set the home directory in the home part of user.present. Paste in the user's SSH key in the ssh_auth section and if you want a password create an entry beginning `password:` in the user.present section and paste in a password hash generated with the `openssl passwd -6` command, DO NOT PUT A PLAINTEXT PASSWORD. If the user is going to need sudo access they must have a password. To enable sudo access ensure that `{{pillar['sudo_group']}}` is set in the groups section of user.present. 

```
Ensure user joebloggs:
  user.present:
    - name: joebloggs
    - password: $6$az39Voqc2xsg79sf$0ZlYVlcIYwKGjBd8FGGvKxgHHlKqWi8vp9byxiYTvoeJgbVJp16r9BhZDclKnPzByHdnkFgnFzLI/mi0Opa8e1
    - enforce_password: false
    - shell: /bin/bash
    - home: /home/joebloggs
    - groups:
      - {{pillar['sudo_group']}}
      - {{pillar['docker_group']}}

ssh key for joebloggs:
   ssh_auth.present:
     - user: joebloggs
     - enc: ssh-ed25519
     - names:
       - ssh-ed25519 AAAAC3fgklfkitlgfhoitr59y joe.bloggs@noc.ac.uk
```

By default the user won't be able to login to any systems, allow them by editing `salt/top.sls` and creating an entry for `user.<username>` under the entry for each system or under the `*` entry for all systems. 

### Adding a new virtualhost 

Here is the process for adding an extra virtual server.

1. Get a DNS entry for your new virtualhost from NOC IT. Tell them the name you want (e.g. mynewserver.noc.ac.uk) and the IP address you want it to point to, currently the IP of our gateway is 192.171.169.87.

2. create pillars for the hostname, forwarding IP, forwarding port and the name of the config files to match. The file to edit is `pillar/webserver.sls`. Using the frontend web server as an example, it has `apache_frontend_virtualserver_config`, `apache_frontend_ssl_virtualserver_config`, `frontend_webserver_ip`, `frontend_webserver_port` and `frontend-hostname`. You'll need to create equivalents of these for your new web service.

3. Create an apache config for the non-SSL and SSL version of the new web host. These need to be created in `salt/apache/files`. They will be deployed to `/etc/apache2/sites-enabled`. Again use the frontend one as an example, it has `frontend.conf` which redirects non-SSL traffic to the SSL (https) webpage. Copy this and change the servername item to match the pillar entry you created in step 1. `frontend-ssl.conf` is the one which does the proxying to the docker container. This needs to know the hostname/IP address running the container and the port number. These should be specified through the pillar.

4. Edit the apache deployment file to enable your new virtual server. Edit `salt/apache/apache.sls` and copy the entries for "create frontend virtualserver" and "create frontend ssl virtualserver" and adjust these to match the name of the pillar variable pointing to your new virtual server config. The source:// address also needs changing to match the name of the files you created in step 2. This doesn't come from a pillar, but this the only place this is referenced.

5. Open the firewall port on the web VM (or whichever VM is running this) for the docker container by editing `pillar/firewall/init.sls`.

6. Deploy the salt config on the gateway. Commit and push all your changes above to the git repository. Run git pull in /srv/salt on the gateway system. Apply the salt rule changes by running `salt-call --local state.apply`

7. Deploy the salt config on the web VM. Login to the web VM from the gateway and run git pull in the /srv/salt directory. Apply the salt rule changes by running `salt-call --local state.apply`. This should update the firewall rules. It might interfere with Docker and require a restart of your docker containers (docker restart <containername>) and/or the docker service (service docker restart). You can verify the firewall port is open with the command `iptables --list TCP -n`

8. Update the SSL certificate to include your new hostname, on gateway run: `certbot certonly --cert-name imfe-pilot.noc.ac.uk --apache -d imfe-pilot-api.noc.ac.uk -d imfe-pilot-mbtiles.noc.ac.uk -d imfe-pilot.noc.ac.uk -d <your new hostname>`

9. reload the apache config with `service apache2 reload`

10. Run your new service on the web VM. Forward the port to the port number you specified in step 1. e.g.` docker run -p 8083:80 <containername>`. Visiting http://new-hostname should connect you to the service running in the container. 
