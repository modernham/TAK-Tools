
# TAK Tools

A (future) collection of tools and scripts for the purpose of automating the install, maintence and upgrading of TAK servers. 

Current Tools:



## Current Tools
## One Line Docker/TAK Server Installer

**Prerequisites**

-A regular non-root user created

-wget Installed

If you are confused about that, you can isntall wget, and create a user with (running as root):
```bash
adduser DESIREDUSERNAME
apt-get install wget
```

Run as the root:

```bash
wget -O - https://raw.githubusercontent.com/modernham/TAK-Tools/main/takinstall.sh | bash
```

## Acknowledgements

 - [TAK SERVER Docker Installer Script  by Cloud-RF (Link to Project)](https://github.com/Cloud-RF/tak-server)


