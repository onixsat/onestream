Now I have a complete picture of the project. Let me write a comprehensive VPS deployment guide tailored to `onestream`.
Action: file_editor create /app/ONESTREAM_VPS_DEPLOYMENT_GUIDE.md --file-text "# OneStream (OnixSat) — VPS Deployment Guide

> A step-by-step guide to install and run the `onixsat/onestream` interactive Bash panel on a real Ubuntu VPS.

`onestream` is an interactive terminal-based server management menu written by **OnixSat** (Portuguese). It installs and manages **nginx, PHP 8.3, certbot (SSL), UFW firewall, iptables**, and opens ports commonly used for IPTV/streaming panels (21, 80, 443, 8080, 8443, 9000).

---

## 1. Requirements

### VPS specs (minimum recommended)
| Item | Minimum | Recommended |
|---|---|---|
| OS | Ubuntu **22.04** LTS (64-bit) — fresh install | Ubuntu 22.04 LTS |
| CPU | 1 vCPU | 2+ vCPU |
| RAM | 2 GB | 4 GB+ |
| Disk | 20 GB SSD | 40 GB+ SSD |
| Bandwidth | Unmetered / 1 TB+ | Unmetered |
| Access | root or a `sudo` user | root via SSH |

### Suggested VPS providers
- **Contabo** (cheap, generous specs) — https://contabo.com
- **Hetzner Cloud** (great EU performance) — https://hetzner.com/cloud
- **DigitalOcean** — https://digitalocean.com
- **Vultr** — https://vultr.com
- **OVH / Kimsufi** — https://ovhcloud.com

### Before you start
- A domain name pointed to the VPS IP (A record) — needed for SSL later.
- Your VPS IP address and root SSH credentials.
- An SSH client:
  - **Windows:** PuTTY, Windows Terminal, or MobaXterm
  - **macOS / Linux:** built-in `ssh`

---

## 2. Connect to your VPS

From your local machine:

```bash
ssh root@YOUR_VPS_IP
```

Type `yes` at the fingerprint prompt, then enter your root password.

If your provider gave you a non-root user, use:
```bash
ssh youruser@YOUR_VPS_IP
sudo -i           # switch to root
```

---

## 3. Run the exact commands from the problem statement

Once logged in as root, run these commands **in order**:

```bash
# Become root (skip if already root)
sudo su

# 1) Refresh package index and upgrade the base system
sudo apt update -y
sudo apt upgrade -y

# 2) Install prerequisites
sudo apt install -y git nano wget dos2unix

# 3) Clone the OneStream repository
git clone https://github.com/onixsat/onestream.git

# 4) Convert Windows CRLF line-endings to Unix LF
#    (the \"fox/*\" from the original doc doesn't exist in this repo,
#     so just run the recursive conversion below — it handles everything)
cd onestream
find . -name '*.sh' -print0 | xargs -0 dos2unix

# 5) Make sure the launcher is executable
chmod +x btk.sh

# 6) Launch the interactive panel
bash btk.sh
```

> ⚠️ **Note:** The line `dos2unix fox/*` from the original snippet refers to a folder that does not exist inside the repo. It's safe to skip — the recursive `find … dos2unix` line already handles every `.sh` file.

---

## 4. Using the OneStream menu

When `btk.sh` starts, you'll see a banner:

```
  _____  _______  _____   ______  _____
 |     | |______ |_____] |_____/ |     |
 |_____| ______| |       |    \_ |_____|
                    Developer: OnixSat
```

Then a text menu appears. Navigate with the **number keys** and **Enter**:

```
Main Menu
  1) Servidor      → server-level actions
  2) Nginx         → nginx config, sites, reload
  3) Extras        → extra utilities
  4) Quit
```

### Typical first-run flow
1. Enter **`1` Servidor** → **Instalar** → **Instalar**
   - Runs `apt update && apt upgrade`.
   - Installs: `ufw`, `net-tools`, `nginx`, `openssh-server`, `certbot`, `python3-certbot-nginx`, `iptables-persistent`, `php8.3-cli`, `php8.3-fpm`, `php8.3-mcrypt`, `curl`.
   - Enables UFW firewall and opens ports **22, 21, 80, 443, 8080, 8443, 9000**.
   - Configures iptables persistence.
   - Press any key each time the script pauses.

2. Enter **`2` Nginx** → configure sites / virtual hosts.
3. Enter **`3` Extras** → optional utilities (Cloudflare, SSL helpers, etc.).

---

## 5. Post-installation — verify everything is running

```bash
# Nginx status
sudo systemctl status nginx --no-pager

# PHP-FPM status
sudo systemctl status php8.3-fpm --no-pager

# Firewall rules
sudo ufw status verbose

# Listening ports
sudo ss -tlnp
```

Visit `http://YOUR_VPS_IP` in a browser — you should see the default Nginx welcome page (or your configured site).

---

## 6. Get a free SSL certificate (Let's Encrypt)

Point your domain's **A record** to `YOUR_VPS_IP` first (allow ~5 min for DNS to propagate).

```bash
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow the prompts (email, ToS, redirect HTTP→HTTPS). Certbot will auto-renew via a systemd timer.

---

## 7. Common issues & fixes

| Symptom | Cause / Fix |
|---|---|
| `bash: ./btk.sh: /bin/bash^M: bad interpreter` | Line endings weren't converted. Re-run: `find . -name '*.sh' -print0 \| xargs -0 dos2unix` |
| `Permission denied` running `btk.sh` | `chmod +x btk.sh` |
| `Unable to locate package php8.3-*` | You're on Ubuntu 20.04 or older. Either upgrade to 22.04, or add the PPA: `sudo add-apt-repository ppa:ondrej/php -y && sudo apt update` |
| UFW locks you out of SSH | Always run `ufw allow 22` **before** `ufw enable`. If locked out, use your provider's web console to disable UFW: `sudo ufw disable` |
| Port 80 already in use | Something else (Apache?) is bound. `sudo systemctl stop apache2 && sudo systemctl disable apache2` |
| Certbot fails with \"connection refused\" | Domain doesn't point to the server yet, or port 80 blocked by provider firewall. Verify DNS: `dig +short yourdomain.com` |
| `sudo apt upgrade` hangs on kernel prompt | Non-interactive mode: `DEBIAN_FRONTEND=noninteractive sudo apt-get -y -o Dpkg::Options::=\"--force-confdef\" -o Dpkg::Options::=\"--force-confold\" upgrade` |

---

## 8. ⚠️ Security warnings before running

`onestream` contains commands that **modify system-level configuration** and, in some code paths, kill all listening processes on the host. **DO NOT run it on a server that already hosts other services.** Use a **fresh, dedicated VPS**.

Specifically the launcher's shutdown hook contains:
```bash
lsof -nP -iTCP -sTCP:LISTEN | sudo xargs kill
```
This will terminate every listening process on the machine.

Also:
- Change the root password after first login: `passwd`
- Create a non-root sudo user for daily use.
- Consider fail2ban: `sudo apt install -y fail2ban`
- Never expose port **21 (FTP)** publicly unless you truly need it — prefer SFTP over port 22.

---

## 9. Uninstall / rollback

```bash
# Stop and disable services installed by the panel
sudo systemctl disable --now nginx php8.3-fpm

# Reset firewall
sudo ufw --force reset

# Remove packages
sudo apt-get purge -y nginx nginx-common php8.3-cli php8.3-fpm php8.3-mcrypt certbot python3-certbot-nginx iptables-persistent
sudo apt-get autoremove -y

# Remove the clone
cd ~ && rm -rf onestream
```

---

## 10. TL;DR — copy-paste block

```bash
ssh root@YOUR_VPS_IP
apt update -y && apt upgrade -y
apt install -y git nano wget dos2unix
git clone https://github.com/onixsat/onestream.git
cd onestream
find . -name '*.sh' -print0 | xargs -0 dos2unix
chmod +x btk.sh
bash btk.sh
```

Then inside the menu: **Servidor → Instalar → Instalar**, follow prompts, and you're up.

---

**Repo:** https://github.com/onixsat/onestream  
**Author:** OnixSat — https://github.com/onixsat
"
Observation: Create successful: /app/ONESTREAM_VPS_DEPLOYMENT_GUIDE.md
