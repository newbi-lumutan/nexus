#!/bin/bash
# ============================================================
#   NEXUS-UDP VPS MANAGER
#   Binary: udp-zivpn-linux-amd64
#   Config: /etc/zivpn/config.json
# ============================================================

# === COLORS ===
R='\033[0;31m'    # Red
G='\033[0;32m'    # Green
Y='\033[1;33m'    # Yellow
B='\033[0;34m'    # Blue
C='\033[0;36m'    # Cyan
M='\033[0;35m'    # Magenta
W='\033[1;37m'    # White Bold
D='\033[2;37m'    # Dim
X='\033[0m'       # Reset
BG='\033[44m'     # Blue BG
RD='\033[41m'     # Red BG
GD='\033[42m'     # Green BG

# === CONFIG ===
BINARY_URL="https://github.com/fauzanihanipah/ziv-udp/releases/download/udp-zivpn/udp-zivpn-linux-amd64"
CONFIG_URL="https://github.com/fauzanihanipah/ziv-udp/raw/main/config.json"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="/etc/zivpn"
BINARY="$INSTALL_DIR/udp-zivpn"
CONFIG="$CONFIG_DIR/config.json"
SERVICE="udp-zivpn"
DB_DIR="/etc/zivpn/users"
BOT_FILE="/etc/zivpn/.botconfig"

mkdir -p "$DB_DIR"

# ============================================================
#   FUNGSI UTILITAS
# ============================================================

clear_screen() { clear; }

press_enter() {
  echo -e "\n${D}  Tekan ${W}[ENTER]${D} untuk kembali ke menu...${X}"
  read -r
}

line() { echo -e "${D}  ════════════════════════════════════════════════${X}"; }
line2() { echo -e "${D}  ────────────────────────────────────────────────${X}"; }

get_ip() { curl -s4 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'; }

service_status() {
  if systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
    echo -e "${GD}${W} RUNNING ${X}"
  else
    echo -e "${RD}${W} STOPPED ${X}"
  fi
}

get_port() {
  if [[ -f "$CONFIG" ]]; then
    grep '"listen"' "$CONFIG" | grep -oP ':\K[0-9]+' 2>/dev/null || echo "5667"
  else
    echo "5667"
  fi
}

count_users() {
  ls "$DB_DIR"/*.conf 2>/dev/null | wc -l
}

# ============================================================
#   LOGO NEXUS-UDP
# ============================================================

show_logo() {
echo -e ""
echo -e "${C}  ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗    ${Y}██╗   ██╗██████╗ ██████╗${X}"
echo -e "${C}  ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝    ${Y}██║   ██║██╔══██╗██╔══██╗${X}"
echo -e "${C}  ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗    ${Y}██║   ██║██║  ██║██████╔╝${X}"
echo -e "${C}  ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║    ${Y}██║   ██║██║  ██║██╔═══╝ ${X}"
echo -e "${C}  ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║    ${Y}╚██████╔╝██████╔╝██║     ${X}"
echo -e "${C}  ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ${Y} ╚═════╝ ╚═════╝ ╚═╝     ${X}"
echo -e "${M}                  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱  ╱${X}"
echo -e "${D}                       P O W E R E D  B Y  Z I V - U D P${X}"
}

# ============================================================
#   INFO VPS LENGKAP
# ============================================================

show_vps_info() {
  local ip=$(get_ip)
  local hostname=$(hostname)
  local os=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
  local kernel=$(uname -r)
  local arch=$(uname -m)
  local uptime=$(uptime -p 2>/dev/null | sed 's/up //')
  local cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | xargs)
  local cpu_cores=$(nproc 2>/dev/null)
  local cpu_usage=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | xargs printf "%.1f")
  local ram_total=$(free -m 2>/dev/null | awk '/Mem/{print $2}')
  local ram_used=$(free -m 2>/dev/null | awk '/Mem/{print $3}')
  local ram_free=$(free -m 2>/dev/null | awk '/Mem/{print $4}')
  local disk_total=$(df -h / 2>/dev/null | awk 'NR==2{print $2}')
  local disk_used=$(df -h / 2>/dev/null | awk 'NR==2{print $3}')
  local disk_free=$(df -h / 2>/dev/null | awk 'NR==2{print $4}')
  local disk_pct=$(df -h / 2>/dev/null | awk 'NR==2{print $5}')
  local isp=$(curl -s --max-time 3 "http://ipinfo.io/org" 2>/dev/null | head -c 50)
  local country=$(curl -s --max-time 3 "http://ipinfo.io/country" 2>/dev/null)
  local timezone=$(timedatectl 2>/dev/null | grep "Time zone" | awk '{print $3}')
  local load=$(cat /proc/loadavg 2>/dev/null | awk '{print $1, $2, $3}')
  local port=$(get_port)
  local svc_status=$(systemctl is-active "$SERVICE" 2>/dev/null)

  line
  echo -e "  ${W}◈  INFO SERVER LENGKAP${X}"
  line
  echo -e "  ${C}🌐 IP Public     ${X}: ${W}$ip${X}  ${D}[$country]${X}"
  echo -e "  ${C}🖥  Hostname      ${X}: ${W}$hostname${X}"
  echo -e "  ${C}💿 OS            ${X}: ${Y}$os${X}"
  echo -e "  ${C}🔧 Kernel        ${X}: $kernel ($arch)"
  echo -e "  ${C}⏱  Uptime        ${X}: ${G}$uptime${X}"
  echo -e "  ${C}🌍 ISP           ${X}: $isp"
  echo -e "  ${C}🕐 Timezone      ${X}: $timezone"
  line2
  echo -e "  ${C}⚙  CPU Model     ${X}: $cpu_model"
  echo -e "  ${C}🔲 CPU Cores     ${X}: $cpu_cores cores  ${D}| Load: $load${X}"
  echo -e "  ${C}📊 CPU Usage     ${X}: ${Y}${cpu_usage}%${X}"
  line2
  echo -e "  ${C}🧠 RAM Total     ${X}: ${ram_total} MB"
  echo -e "  ${C}🔴 RAM Used      ${X}: ${Y}${ram_used} MB${X}"
  echo -e "  ${C}🟢 RAM Free      ${X}: ${G}${ram_free} MB${X}"
  line2
  echo -e "  ${C}💾 Disk Total    ${X}: $disk_total"
  echo -e "  ${C}🔴 Disk Used     ${X}: ${Y}$disk_used ($disk_pct)${X}"
  echo -e "  ${C}🟢 Disk Free     ${X}: ${G}$disk_free${X}"
  line2
  echo -e "  ${C}🚀 UDP-ZivVPN   ${X}: Port ${W}$port${X}  Status: $(service_status)"
  echo -e "  ${C}👥 Total User    ${X}: ${W}$(count_users) akun${X}"
  line
}

# ============================================================
#   HEADER MENU UTAMA
# ============================================================

show_header() {
  clear_screen
  show_logo
  echo ""
  show_vps_info
  echo ""
}

# ============================================================
#   MENU UTAMA
# ============================================================

main_menu() {
  show_header
  echo -e "  ${W}◈  MENU UTAMA${X}"
  line
  echo -e "  ${C}[${W}1${C}]${X}  👤  Kelola Akun UDP"
  echo -e "  ${C}[${W}2${C}]${X}  ⚙️   Kelola Layanan UDP"
  echo -e "  ${C}[${W}3${C}]${X}  🔧  Konfigurasi Server"
  echo -e "  ${C}[${W}4${C}]${X}  🤖  Telegram Bot"
  echo -e "  ${C}[${W}5${C}]${X}  📊  Monitor & Statistik"
  echo -e "  ${C}[${W}6${C}]${X}  🔄  Update / Reinstall"
  echo -e "  ${C}[${W}0${C}]${X}  ❌  Keluar"
  line
  echo -ne "  ${W}Pilih menu ${C}[0-6]${W}: ${X}"
  read -r choice
  case $choice in
    1) menu_akun ;;
    2) menu_layanan ;;
    3) menu_konfigurasi ;;
    4) menu_telegram ;;
    5) menu_monitor ;;
    6) menu_update ;;
    0) echo -e "\n  ${G}Sampai jumpa! 👋${X}\n"; exit 0 ;;
    *) echo -e "\n  ${R}Pilihan tidak valid!${X}"; sleep 1; main_menu ;;
  esac
}

# ============================================================
#   MENU AKUN
# ============================================================

menu_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  KELOLA AKUN UDP${X}"
  line
  echo -e "  ${C}[${W}1${C}]${X}  ➕  Buat Akun Baru"
  echo -e "  ${C}[${W}2${C}]${X}  📋  List Semua Akun"
  echo -e "  ${C}[${W}3${C}]${X}  🔍  Cek Detail Akun"
  echo -e "  ${C}[${W}4${C}]${X}  🗑️   Hapus Akun"
  echo -e "  ${C}[${W}5${C}]${X}  ♻️   Perpanjang Akun"
  echo -e "  ${C}[${W}6${C}]${X}  📤  Kirim Akun ke Telegram"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-6]${W}: ${X}"
  read -r choice
  case $choice in
    1) buat_akun ;;
    2) list_akun ;;
    3) cek_akun ;;
    4) hapus_akun ;;
    5) perpanjang_akun ;;
    6) kirim_telegram ;;
    0) main_menu ;;
    *) echo -e "\n  ${R}Pilihan tidak valid!${X}"; sleep 1; menu_akun ;;
  esac
}

buat_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  BUAT AKUN BARU${X}"
  line
  echo -ne "  ${C}Username    ${W}: ${X}"; read -r username
  echo -ne "  ${C}Password    ${W}: ${X}"; read -r password
  echo -ne "  ${C}Masa Aktif  ${W}(hari): ${X}"; read -r days

  if [[ -z "$username" || -z "$password" || -z "$days" ]]; then
    echo -e "\n  ${R}[✗] Semua field wajib diisi!${X}"; press_enter; menu_akun; return
  fi

  local exp_date=$(date -d "+${days} days" +"%Y-%m-%d" 2>/dev/null || date -v+${days}d +"%Y-%m-%d")
  local ip=$(get_ip)
  local port=$(get_port)
  local created=$(date +"%Y-%m-%d %H:%M:%S")

  # Simpan ke file
  cat > "$DB_DIR/${username}.conf" <<EOF
USERNAME=$username
PASSWORD=$password
EXPIRED=$exp_date
CREATED=$created
IP=$ip
PORT=$port
EOF

  # Update config.json - tambah password
  if [[ -f "$CONFIG" ]]; then
    local cur_pass=$(grep -oP '"config":\s*\[\K[^\]]+' "$CONFIG" | tr -d ' "')
    local new_pass="\"$cur_pass\", \"$password\""
    # Simple append ke passwords array
    python3 -c "
import json
with open('$CONFIG','r') as f: c=json.load(f)
if '$password' not in c['auth']['config']:
    c['auth']['config'].append('$password')
with open('$CONFIG','w') as f: json.dump(c,f,indent=2)
" 2>/dev/null
    systemctl restart "$SERVICE" 2>/dev/null
  fi

  line
  echo -e "  ${G}[✓] Akun berhasil dibuat!${X}"
  line2
  echo -e "  ${C}Username   ${X}: ${W}$username${X}"
  echo -e "  ${C}Password   ${X}: ${W}$password${X}"
  echo -e "  ${C}IP Server  ${X}: ${W}$ip${X}"
  echo -e "  ${C}Port UDP   ${X}: ${W}$port${X}"
  echo -e "  ${C}Obfs       ${X}: ${W}zivpn${X}"
  echo -e "  ${C}Expired    ${X}: ${Y}$exp_date${X}"
  line

  press_enter; menu_akun
}

list_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  LIST SEMUA AKUN${X}"
  line
  local today=$(date +"%Y-%m-%d")
  local count=0

  for f in "$DB_DIR"/*.conf; do
    [[ -f "$f" ]] || continue
    source "$f"
    count=$((count+1))
    local status=""
    if [[ "$EXPIRED" < "$today" ]]; then
      status="${R}[EXPIRED]${X}"
    else
      status="${G}[AKTIF]  ${X}"
    fi
    echo -e "  ${C}$count.${X} ${W}$USERNAME${X} | Pass: $PASSWORD | Exp: ${Y}$EXPIRED${X} $status"
  done

  [[ $count -eq 0 ]] && echo -e "  ${D}Belum ada akun.${X}"
  echo -e "\n  ${D}Total: ${W}$count akun${X}"
  line
  press_enter; menu_akun
}

cek_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  CEK DETAIL AKUN${X}"
  line
  echo -ne "  ${C}Username: ${X}"; read -r username
  local f="$DB_DIR/${username}.conf"
  if [[ ! -f "$f" ]]; then
    echo -e "\n  ${R}[✗] Akun tidak ditemukan!${X}"; press_enter; menu_akun; return
  fi
  source "$f"
  local today=$(date +"%Y-%m-%d")
  local sisa=$(( ($(date -d "$EXPIRED" +%s) - $(date +%s)) / 86400 ))
  [[ $sisa -lt 0 ]] && sisa=0

  line2
  echo -e "  ${C}Username   ${X}: ${W}$USERNAME${X}"
  echo -e "  ${C}Password   ${X}: ${W}$PASSWORD${X}"
  echo -e "  ${C}IP Server  ${X}: ${W}$IP${X}"
  echo -e "  ${C}Port UDP   ${X}: ${W}$PORT${X}"
  echo -e "  ${C}Obfs       ${X}: ${W}zivpn${X}"
  echo -e "  ${C}Dibuat     ${X}: $CREATED"
  echo -e "  ${C}Expired    ${X}: ${Y}$EXPIRED${X}"
  echo -e "  ${C}Sisa Hari  ${X}: ${G}$sisa hari${X}"
  line
  press_enter; menu_akun
}

hapus_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  HAPUS AKUN${X}"
  line
  echo -ne "  ${C}Username yang dihapus: ${X}"; read -r username
  local f="$DB_DIR/${username}.conf"
  if [[ ! -f "$f" ]]; then
    echo -e "\n  ${R}[✗] Akun tidak ditemukan!${X}"; press_enter; menu_akun; return
  fi
  source "$f"
  echo -ne "  ${Y}Yakin hapus akun ${W}$username${Y}? (y/N): ${X}"; read -r confirm
  if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
    # Hapus password dari config
    python3 -c "
import json
with open('$CONFIG','r') as f: c=json.load(f)
if '$PASSWORD' in c['auth']['config']:
    c['auth']['config'].remove('$PASSWORD')
with open('$CONFIG','w') as f: json.dump(c,f,indent=2)
" 2>/dev/null
    rm -f "$f"
    systemctl restart "$SERVICE" 2>/dev/null
    echo -e "\n  ${G}[✓] Akun $username berhasil dihapus!${X}"
  else
    echo -e "\n  ${D}Dibatalkan.${X}"
  fi
  press_enter; menu_akun
}

perpanjang_akun() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  PERPANJANG AKUN${X}"
  line
  echo -ne "  ${C}Username: ${X}"; read -r username
  local f="$DB_DIR/${username}.conf"
  if [[ ! -f "$f" ]]; then
    echo -e "\n  ${R}[✗] Akun tidak ditemukan!${X}"; press_enter; menu_akun; return
  fi
  source "$f"
  echo -e "  ${D}Expired saat ini: ${Y}$EXPIRED${X}"
  echo -ne "  ${C}Tambah berapa hari: ${X}"; read -r days
  local new_exp=$(date -d "$EXPIRED +${days} days" +"%Y-%m-%d" 2>/dev/null)
  sed -i "s/EXPIRED=.*/EXPIRED=$new_exp/" "$f"
  echo -e "\n  ${G}[✓] Akun diperpanjang hingga ${Y}$new_exp${X}"
  press_enter; menu_akun
}

kirim_telegram() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  KIRIM AKUN KE TELEGRAM${X}"
  line
  if [[ ! -f "$BOT_FILE" ]]; then
    echo -e "  ${R}[✗] Bot Telegram belum dikonfigurasi!${X}"
    echo -e "  ${D}Pergi ke menu Telegram Bot terlebih dahulu.${X}"
    press_enter; menu_akun; return
  fi
  source "$BOT_FILE"
  echo -ne "  ${C}Username akun: ${X}"; read -r username
  local f="$DB_DIR/${username}.conf"
  if [[ ! -f "$f" ]]; then
    echo -e "\n  ${R}[✗] Akun tidak ditemukan!${X}"; press_enter; menu_akun; return
  fi
  source "$f"
  local msg="🔐 *INFO AKUN UDP-ZivVPN*%0A%0A"
  msg+="👤 Username : \`$USERNAME\`%0A"
  msg+="🔑 Password : \`$PASSWORD\`%0A"
  msg+="🌐 IP Server: \`$IP\`%0A"
  msg+="🚀 Port UDP : \`$PORT\`%0A"
  msg+="🔧 Obfs     : \`zivpn\`%0A"
  msg+="📅 Expired  : \`$EXPIRED\`"

  local result=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${msg}&parse_mode=Markdown")
  if echo "$result" | grep -q '"ok":true'; then
    echo -e "\n  ${G}[✓] Akun berhasil dikirim ke Telegram!${X}"
  else
    echo -e "\n  ${R}[✗] Gagal kirim! Cek token dan chat_id.${X}"
  fi
  press_enter; menu_akun
}

# ============================================================
#   MENU LAYANAN
# ============================================================

menu_layanan() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  KELOLA LAYANAN UDP${X}  Status: $(service_status)"
  line
  echo -e "  ${C}[${W}1${C}]${X}  ▶️   Start UDP-ZivVPN"
  echo -e "  ${C}[${W}2${C}]${X}  ⏹️   Stop UDP-ZivVPN"
  echo -e "  ${C}[${W}3${C}]${X}  🔄  Restart UDP-ZivVPN"
  echo -e "  ${C}[${W}4${C}]${X}  📋  Lihat Log Realtime"
  echo -e "  ${C}[${W}5${C}]${X}  📋  Lihat Log Terakhir"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-5]${W}: ${X}"
  read -r choice
  case $choice in
    1) systemctl start "$SERVICE" && echo -e "\n  ${G}[✓] Service started!${X}" || echo -e "\n  ${R}[✗] Gagal start!${X}"; press_enter; menu_layanan ;;
    2) systemctl stop "$SERVICE" && echo -e "\n  ${Y}[!] Service stopped.${X}"; press_enter; menu_layanan ;;
    3) systemctl restart "$SERVICE" && echo -e "\n  ${G}[✓] Service restarted!${X}"; press_enter; menu_layanan ;;
    4) echo -e "\n  ${D}CTRL+C untuk keluar...${X}\n"; journalctl -u "$SERVICE" -f ;;
    5) journalctl -u "$SERVICE" -n 30 --no-pager; press_enter; menu_layanan ;;
    0) main_menu ;;
    *) menu_layanan ;;
  esac
}

# ============================================================
#   MENU KONFIGURASI
# ============================================================

menu_konfigurasi() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  KONFIGURASI SERVER${X}"
  line
  echo -e "  ${C}[${W}1${C}]${X}  🔌  Ganti Port UDP"
  echo -e "  ${C}[${W}2${C}]${X}  🔑  Ganti Obfs Key"
  echo -e "  ${C}[${W}3${C}]${X}  📄  Lihat Config Saat Ini"
  echo -e "  ${C}[${W}4${C}]${X}  🔒  Regenerate SSL Cert"
  echo -e "  ${C}[${W}5${C}]${X}  🌐  Cek Port Terbuka"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-5]${W}: ${X}"
  read -r choice
  case $choice in
    1) ganti_port ;;
    2) ganti_obfs ;;
    3) lihat_config ;;
    4) regen_ssl ;;
    5) cek_port ;;
    0) main_menu ;;
    *) menu_konfigurasi ;;
  esac
}

ganti_port() {
  echo -ne "\n  ${C}Port baru: ${X}"; read -r port
  if [[ -f "$CONFIG" ]]; then
    python3 -c "
import json
with open('$CONFIG','r') as f: c=json.load(f)
c['listen']=':$port'
with open('$CONFIG','w') as f: json.dump(c,f,indent=2)
" 2>/dev/null
    systemctl restart "$SERVICE" 2>/dev/null
    echo -e "  ${G}[✓] Port diubah ke $port, service direstart.${X}"
  fi
  press_enter; menu_konfigurasi
}

ganti_obfs() {
  echo -ne "\n  ${C}Obfs key baru: ${X}"; read -r obfs
  if [[ -f "$CONFIG" ]]; then
    python3 -c "
import json
with open('$CONFIG','r') as f: c=json.load(f)
c['obfs']='$obfs'
with open('$CONFIG','w') as f: json.dump(c,f,indent=2)
" 2>/dev/null
    systemctl restart "$SERVICE" 2>/dev/null
    echo -e "  ${G}[✓] Obfs diubah ke '$obfs'.${X}"
  fi
  press_enter; menu_konfigurasi
}

lihat_config() {
  echo ""
  line
  echo -e "  ${W}◈  CONFIG: $CONFIG${X}"
  line
  cat "$CONFIG" 2>/dev/null | python3 -m json.tool 2>/dev/null || echo -e "  ${R}Config tidak ditemukan!${X}"
  line
  press_enter; menu_konfigurasi
}

regen_ssl() {
  echo -e "\n  ${Y}[*] Regenerate SSL Certificate...${X}"
  openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "$CONFIG_DIR/zivpn.key" \
    -out "$CONFIG_DIR/zivpn.crt" \
    -days 3650 -subj "/C=ID/O=NexusUDP/CN=nexus" > /dev/null 2>&1
  systemctl restart "$SERVICE" 2>/dev/null
  echo -e "  ${G}[✓] SSL cert baru dibuat (10 tahun).${X}"
  press_enter; menu_konfigurasi
}

cek_port() {
  local port=$(get_port)
  echo -e "\n  ${Y}[*] Cek port $port/udp...${X}"
  if command -v ss &>/dev/null; then
    ss -ulnp | grep ":$port" && echo -e "  ${G}[✓] Port $port/udp TERBUKA${X}" || echo -e "  ${R}[✗] Port $port/udp tidak aktif${X}"
  fi
  press_enter; menu_konfigurasi
}

# ============================================================
#   MENU TELEGRAM BOT
# ============================================================

menu_telegram() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  TELEGRAM BOT${X}"
  line
  if [[ -f "$BOT_FILE" ]]; then
    source "$BOT_FILE"
    echo -e "  ${G}[✓] Bot terhubung${X}"
    echo -e "  ${D}Token : ${W}${BOT_TOKEN:0:20}...${X}"
    echo -e "  ${D}Chat  : ${W}$CHAT_ID${X}"
  else
    echo -e "  ${R}[✗] Bot belum dikonfigurasi${X}"
  fi
  line2
  echo -e "  ${C}[${W}1${C}]${X}  🔗  Hubungkan Bot Telegram"
  echo -e "  ${C}[${W}2${C}]${X}  📤  Test Kirim Pesan"
  echo -e "  ${C}[${W}3${C}]${X}  📊  Kirim Info VPS ke Bot"
  echo -e "  ${C}[${W}4${C}]${X}  👥  Kirim Semua Akun ke Bot"
  echo -e "  ${C}[${W}5${C}]${X}  🔔  Notif Auto (On/Off)"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-5]${W}: ${X}"
  read -r choice
  case $choice in
    1) setup_bot ;;
    2) test_bot ;;
    3) kirim_info_vps ;;
    4) kirim_semua_akun ;;
    5) toggle_notif ;;
    0) main_menu ;;
    *) menu_telegram ;;
  esac
}

setup_bot() {
  clear_screen
  echo ""
  line
  echo -e "  ${W}◈  SETUP TELEGRAM BOT${X}"
  line
  echo -e "  ${D}Buat bot di @BotFather dan dapatkan token.${X}"
  echo -e "  ${D}Chat ID: kirim /start ke @userinfobot${X}"
  echo ""
  echo -ne "  ${C}BOT TOKEN : ${X}"; read -r token
  echo -ne "  ${C}CHAT ID   : ${X}"; read -r chatid

  cat > "$BOT_FILE" <<EOF
BOT_TOKEN=$token
CHAT_ID=$chatid
NOTIF_ENABLED=false
EOF

  local test=$(curl -s "https://api.telegram.org/bot${token}/getMe")
  if echo "$test" | grep -q '"ok":true'; then
    local botname=$(echo "$test" | grep -oP '"username":"\K[^"]+')
    echo -e "\n  ${G}[✓] Bot @$botname berhasil terhubung!${X}"
  else
    echo -e "\n  ${R}[✗] Token tidak valid!${X}"
  fi
  press_enter; menu_telegram
}

test_bot() {
  [[ ! -f "$BOT_FILE" ]] && echo -e "\n  ${R}Bot belum dikonfigurasi!${X}" && press_enter && menu_telegram && return
  source "$BOT_FILE"
  local msg="✅ NEXUS-UDP Test Message%0AServer: $(get_ip)%0AStatus: OK"
  local r=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${msg}")
  echo "$r" | grep -q '"ok":true' && echo -e "\n  ${G}[✓] Pesan terkirim!${X}" || echo -e "\n  ${R}[✗] Gagal kirim!${X}"
  press_enter; menu_telegram
}

kirim_info_vps() {
  [[ ! -f "$BOT_FILE" ]] && echo -e "\n  ${R}Bot belum dikonfigurasi!${X}" && press_enter && menu_telegram && return
  source "$BOT_FILE"
  local ip=$(get_ip)
  local ram_used=$(free -m | awk '/Mem/{print $3}')
  local ram_total=$(free -m | awk '/Mem/{print $2}')
  local disk=$(df -h / | awk 'NR==2{print $3"/"$2}')
  local uptime=$(uptime -p | sed 's/up //')
  local port=$(get_port)
  local users=$(count_users)
  local svc=$(systemctl is-active "$SERVICE" 2>/dev/null)

  local msg="🖥 *INFO VPS NEXUS-UDP*%0A%0A"
  msg+="🌐 IP     : \`$ip\`%0A"
  msg+="🚀 Port   : \`$port\`%0A"
  msg+="📊 Status : \`$svc\`%0A"
  msg+="🧠 RAM    : ${ram_used}/${ram_total} MB%0A"
  msg+="💾 Disk   : $disk%0A"
  msg+="⏱ Uptime : $uptime%0A"
  msg+="👥 Users  : $users akun"

  local r=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${msg}&parse_mode=Markdown")
  echo "$r" | grep -q '"ok":true' && echo -e "\n  ${G}[✓] Info VPS terkirim!${X}" || echo -e "\n  ${R}[✗] Gagal!${X}"
  press_enter; menu_telegram
}

kirim_semua_akun() {
  [[ ! -f "$BOT_FILE" ]] && echo -e "\n  ${R}Bot belum dikonfigurasi!${X}" && press_enter && menu_telegram && return
  source "$BOT_FILE"
  local count=0
  for f in "$DB_DIR"/*.conf; do
    [[ -f "$f" ]] || continue
    source "$f"
    count=$((count+1))
    local msg="👤 *Akun #$count*%0A"
    msg+="Username : \`$USERNAME\`%0A"
    msg+="Password : \`$PASSWORD\`%0A"
    msg+="IP       : \`$IP\`%0A"
    msg+="Port     : \`$PORT\`%0A"
    msg+="Expired  : \`$EXPIRED\`"
    curl -s "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${msg}&parse_mode=Markdown" > /dev/null
    sleep 0.3
  done
  [[ $count -eq 0 ]] && echo -e "\n  ${D}Tidak ada akun.${X}" || echo -e "\n  ${G}[✓] $count akun terkirim ke Telegram!${X}"
  press_enter; menu_telegram
}

toggle_notif() {
  [[ ! -f "$BOT_FILE" ]] && echo -e "\n  ${R}Bot belum dikonfigurasi!${X}" && press_enter && menu_telegram && return
  source "$BOT_FILE"
  if [[ "$NOTIF_ENABLED" == "true" ]]; then
    sed -i "s/NOTIF_ENABLED=.*/NOTIF_ENABLED=false/" "$BOT_FILE"
    echo -e "\n  ${Y}[!] Notifikasi otomatis DIMATIKAN.${X}"
  else
    sed -i "s/NOTIF_ENABLED=.*/NOTIF_ENABLED=true/" "$BOT_FILE"
    echo -e "\n  ${G}[✓] Notifikasi otomatis DIAKTIFKAN.${X}"
  fi
  press_enter; menu_telegram
}

# ============================================================
#   MENU MONITOR
# ============================================================

menu_monitor() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  MONITOR & STATISTIK${X}"
  line
  echo -e "  ${C}[${W}1${C}]${X}  📊  Realtime Resource (CPU/RAM)"
  echo -e "  ${C}[${W}2${C}]${X}  🌐  Cek Koneksi Aktif"
  echo -e "  ${C}[${W}3${C}]${X}  📅  Akun Akan Expired"
  echo -e "  ${C}[${W}4${C}]${X}  🔁  Ping Test"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-4]${W}: ${X}"
  read -r choice
  case $choice in
    1) watch -n1 "free -h && echo '' && top -bn1 | head -20" ;;
    2) ss -anup 2>/dev/null | head -30; press_enter; menu_monitor ;;
    3) cek_expired ;;
    4) echo -ne "\n  ${C}Host: ${X}"; read -r host; ping -c 4 "$host"; press_enter; menu_monitor ;;
    0) main_menu ;;
    *) menu_monitor ;;
  esac
}

cek_expired() {
  echo ""
  line
  echo -e "  ${W}◈  AKUN MENDEKATI EXPIRED (≤7 hari)${X}"
  line
  local today=$(date +%s)
  local found=0
  for f in "$DB_DIR"/*.conf; do
    [[ -f "$f" ]] || continue
    source "$f"
    local exp_s=$(date -d "$EXPIRED" +%s 2>/dev/null)
    local diff=$(( (exp_s - today) / 86400 ))
    if [[ $diff -le 7 ]]; then
      found=$((found+1))
      echo -e "  ${Y}⚠ $USERNAME${X} - Expired: ${R}$EXPIRED${X} (${diff} hari lagi)"
    fi
  done
  [[ $found -eq 0 ]] && echo -e "  ${G}Semua akun masih aman.${X}"
  line
  press_enter; menu_monitor
}

# ============================================================
#   MENU UPDATE
# ============================================================

menu_update() {
  clear_screen
  show_logo
  echo ""
  line
  echo -e "  ${W}◈  UPDATE / REINSTALL${X}"
  line
  echo -e "  ${C}[${W}1${C}]${X}  ⬆️   Update Binary UDP-ZivVPN"
  echo -e "  ${C}[${W}2${C}]${X}  🔄  Reset Config ke Default"
  echo -e "  ${C}[${W}3${C}]${X}  🗑️   Uninstall Semua"
  echo -e "  ${C}[${W}0${C}]${X}  🔙  Kembali"
  line
  echo -ne "  ${W}Pilih ${C}[0-3]${W}: ${X}"
  read -r choice
  case $choice in
    1)
      echo -e "\n  ${Y}[*] Mengupdate binary...${X}"
      systemctl stop "$SERVICE" 2>/dev/null
      wget -q --show-progress -O "$BINARY" "$BINARY_URL"
      chmod +x "$BINARY"
      systemctl start "$SERVICE" 2>/dev/null
      echo -e "  ${G}[✓] Update selesai!${X}"
      press_enter; menu_update ;;
    2)
      echo -ne "\n  ${R}Yakin reset config? (y/N): ${X}"; read -r c
      if [[ "$c" == "y" ]]; then
        wget -q -O "$CONFIG" "$CONFIG_URL"
        systemctl restart "$SERVICE" 2>/dev/null
        echo -e "  ${G}[✓] Config direset ke default.${X}"
      fi
      press_enter; menu_update ;;
    3)
      echo -ne "\n  ${R}Yakin UNINSTALL semua? (y/N): ${X}"; read -r c
      if [[ "$c" == "y" ]]; then
        systemctl stop "$SERVICE" 2>/dev/null
        systemctl disable "$SERVICE" 2>/dev/null
        rm -f "/etc/systemd/system/${SERVICE}.service"
        rm -f "$BINARY"
        rm -rf "$CONFIG_DIR"
        systemctl daemon-reload
        echo -e "  ${G}[✓] Uninstall selesai.${X}"
        exit 0
      fi
      press_enter; menu_update ;;
    0) main_menu ;;
    *) menu_update ;;
  esac
}

# ============================================================
#   SETUP AUTO-LOAD (ketik 'menu' saat login)
# ============================================================

install_autoload() {
  local script_path=$(realpath "$0")
  local bashrc="$HOME/.bashrc"
  if ! grep -q "nexus-udp" "$bashrc" 2>/dev/null; then
    cat >> "$bashrc" <<EOF

# NEXUS-UDP Auto Menu
menu() { bash $script_path; }
EOF
    echo -e "  ${G}[✓] Ketik ${W}menu${G} untuk membuka NEXUS-UDP Manager!${X}"
  fi
}

# ============================================================
#   MAIN
# ============================================================

# Install autoload jika belum
install_autoload 2>/dev/null

# Mulai menu utama
main_menu
