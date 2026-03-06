#!/bin/bash
# ================================================================
#   OGH-ZIV PREMIUM — UDP VPN MANAGER
#   Binary : github.com/fauzanihanipah/ziv-udp
# ================================================================

# ── PATH ─────────────────────────────────────────────────────────
DIR="/etc/zivpn"
BIN="/usr/local/bin/zivpn"
CFG="$DIR/config.json"
SVC="/etc/systemd/system/zivpn.service"
BINARY_URL="https://github.com/fauzanihanipah/ziv-udp/releases/download/udp-zivpn/udp-zivpn-linux-amd64"
UDB="$DIR/users.db"
LOG="$DIR/zivpn.log"
DOMF="$DIR/domain.conf"
BOTF="$DIR/bot.conf"
STRF="$DIR/store.conf"
THEMEF="$DIR/theme.conf"

# ── UTILS ─────────────────────────────────────────────────────────
check_root() { [[ $EUID -ne 0 ]] && { echo -e "\n\033[1;31m✘ Jalankan sebagai root!\033[0m\n"; exit 1; }; }
ok()    { echo -e "  ${A2}✔${NC}  $*"; }
inf()   { echo -e "  ${A3}➜${NC}  $*"; }
warn()  { echo -e "  ${A4}⚠${NC}  $*"; }
err()   { echo -e "  \033[1;31m✘${NC}  $*"; }
pause() { echo ""; echo -ne "  ${DIM}╰─ [ Enter ] kembali ke menu...${NC}"; read -r; }

get_ip()     { curl -s4 --max-time 5 ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}'; }
get_port()   { grep -o '"listen":":[0-9]*"\|"listen": *":[0-9]*"' "$CFG" 2>/dev/null | grep -o '[0-9]*' || echo "5667"; }
get_domain() { cat "$DOMF" 2>/dev/null || get_ip; }
is_up()      { systemctl is-active --quiet zivpn 2>/dev/null; }
total_user() { [[ -f "$UDB" ]] && grep -c '' "$UDB" 2>/dev/null || echo 0; }
exp_count()  {
    local t; t=$(date +%Y-%m-%d)
    [[ -f "$UDB" ]] && awk -F'|' -v d="$t" '$3<d{c++}END{print c+0}' "$UDB" || echo 0
}
rand_pass()  { tr -dc 'A-Za-z0-9' </dev/urandom | head -c 12; }

# ════════════════════════════════════════════════════════════════
#  SISTEM TEMA WARNA
# ════════════════════════════════════════════════════════════════
# Tema tersedia:
#  1 = VIOLET  (default)
#  2 = CYAN    (neon biru)
#  3 = GREEN   (matrix hijau)
#  4 = GOLD    (emas premium)
#  5 = RED     (merah gelap)
#  6 = PINK    (pink pastel)

load_theme() {
    local theme=1
    [[ -f "$THEMEF" ]] && theme=$(cat "$THEMEF" 2>/dev/null)

    case "$theme" in
        2) # CYAN
            A1='\033[38;5;51m'   # Frame / border
            A2='\033[1;36m'      # OK / aksen terang
            A3='\033[0;36m'      # Info
            A4='\033[1;33m'      # Warn
            AL='\033[38;5;87m'   # Logo aksen
            AT='\033[1;37m'      # Teks bold
            THEME_NAME="CYAN"
            ;;
        3) # GREEN
            A1='\033[38;5;46m'
            A2='\033[1;32m'
            A3='\033[0;32m'
            A4='\033[1;33m'
            AL='\033[38;5;82m'
            AT='\033[1;37m'
            THEME_NAME="GREEN"
            ;;
        4) # GOLD
            A1='\033[38;5;220m'
            A2='\033[1;33m'
            A3='\033[38;5;214m'
            A4='\033[0;33m'
            AL='\033[38;5;226m'
            AT='\033[1;37m'
            THEME_NAME="GOLD"
            ;;
        5) # RED
            A1='\033[38;5;196m'
            A2='\033[1;31m'
            A3='\033[0;31m'
            A4='\033[1;33m'
            AL='\033[38;5;203m'
            AT='\033[1;37m'
            THEME_NAME="RED"
            ;;
        6) # PINK
            A1='\033[38;5;213m'
            A2='\033[1;35m'
            A3='\033[0;35m'
            A4='\033[1;33m'
            AL='\033[38;5;219m'
            AT='\033[1;37m'
            THEME_NAME="PINK"
            ;;
        *) # VIOLET (default)
            A1='\033[38;5;135m'
            A2='\033[1;35m'
            A3='\033[38;5;141m'
            A4='\033[1;33m'
            AL='\033[38;5;141m'
            AT='\033[38;5;231m'
            THEME_NAME="VIOLET"
            ;;
    esac

    NC='\033[0m'
    BLD='\033[1m'
    DIM='\033[2m'
    IT='\033[3m'
    W='\033[1;37m'
    LG='\033[1;32m'
    LR='\033[1;31m'
    LC='\033[1;36m'
    Y='\033[1;33m'
}

# ════════════════════════════════════════════════════════════════
#  MENU TEMA
# ════════════════════════════════════════════════════════════════
menu_tema() {
    while true; do
        clear
        load_theme
        local cur_theme
        cur_theme=$(cat "$THEMEF" 2>/dev/null || echo 1)

        echo ""
        echo -e "  ${A1}╔══════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${A1}║${NC}  ${IT}${AL}  🎨  PILIH TEMA WARNA${NC}                           ${A1}║${NC}"
        echo -e "  ${A1}╠══════════════════════════════════════════════════════╣${NC}"
        echo -e "  ${A1}║${NC}                                                      ${A1}║${NC}"

        local themes=("VIOLET  — Ungu Premium" "CYAN    — Neon Biru" "GREEN   — Matrix Hijau" "GOLD    — Emas Mewah" "RED     — Merah Elegan" "PINK    — Pink Pastel")
        local icons=("💜" "🩵" "💚" "💛" "❤️" "🩷")
        local nums=(1 2 3 4 5 6)
        for i in "${!themes[@]}"; do
            local n=$((i+1))
            local mark="   "
            [[ "$cur_theme" == "$n" ]] && mark="${A2}▶${NC} "
            printf  "  ${A1}║${NC}    %b${icons[$i]}  ${A1}[%s]${NC}  %-30s        ${A1}║${NC}\n" "$mark" "$n" "${themes[$i]}"
        done

        echo -e "  ${A1}║${NC}                                                      ${A1}║${NC}"
        echo -e "  ${A1}╠══════════════════════════════════════════════════════╣${NC}"
        echo -e "  ${A1}║${NC}  ${DIM}Tema aktif sekarang : ${AT}${THEME_NAME}${NC}                        ${A1}║${NC}"
        echo -e "  ${A1}╠══════════════════════════════════════════════════════╣${NC}"
        echo -e "  ${A1}║${NC}  ${LR}[0]${NC}  ◀  Kembali ke menu utama                      ${A1}║${NC}"
        echo -e "  ${A1}╚══════════════════════════════════════════════════════╝${NC}"
        echo ""
        echo -ne "  ${A1}›${NC} Pilih tema [0-6]: "
        read -r ch
        case $ch in
            [1-6])
                echo "$ch" > "$THEMEF"
                load_theme
                ok "Tema ${AT}${THEME_NAME}${NC} aktif!"
                sleep 0.8
                ;;
            0) break ;;
            *) warn "Pilihan tidak valid!"; sleep 0.5 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════════
#  LOGO OGH-ZIV — SEJAJAR, PRESISI, DENGAN GARIS MIRING
# ════════════════════════════════════════════════════════════════
draw_logo() {
    echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${A1}║${NC}                                                          ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT}  ██████╗  ██████╗ ██╗  ██╗${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT} ██╔═══██╗██╔════╝ ██║  ██║${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT} ██║   ██║██║  ███╗███████║${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT} ██║   ██║██║   ██║██╔══██║${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT} ╚██████╔╝╚██████╔╝██║  ██║${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT}  ╚═════╝  ╚═════╝ ╚═╝  ╚═╝${NC}                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}                                                          ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT} ███████╗██╗██╗   ██╗${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT} ╚══███╔╝██║██║   ██║${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT}    ███╔╝ ██║██║   ██║${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT}   ███╔╝  ██║╚██╗ ██╔╝${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT}  ███████╗██║ ╚████╔╝ ${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}              ${AT}${IT}  ╚══════╝╚═╝  ╚═══╝  ${NC}                    ${A1}║${NC}"
    echo -e "  ${A1}║${NC}                                                          ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${DIM}  ╱╱╱╱╱╱╱╱╱╱╱╱╱╱  P R E M I U M  ╱╱╱╱╱╱╱╱╱╱╱╱╱╱${NC}  ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${AL}${IT}✦ OGH-ZIV Premium${NC}  ${DIM}·  fauzanihanipah/ziv-udp  ·  ${AT}v2.0${NC}  ${A1}║${NC}"
    echo -e "  ${A1}╚══════════════════════════════════════════════════════════╝${NC}"
}

# ════════════════════════════════════════════════════════════════
#  INFO VPS
# ════════════════════════════════════════════════════════════════
draw_vps() {
    local ip;     ip=$(get_ip)
    local port;   port=$(get_port)
    local domain; domain=$(get_domain)
    local ram_u;  ram_u=$(free -m | awk '/^Mem/{print $3}')
    local ram_t;  ram_t=$(free -m | awk '/^Mem/{print $2}')
    local cpu;    cpu=$(top -bn1 2>/dev/null | grep "Cpu(s)" | awk '{printf "%.1f",$2}' || echo "?")
    local du;     du=$(df -h / | awk 'NR==2{print $3}')
    local dt;     dt=$(df -h / | awk 'NR==2{print $2}')
    local os;     os=$(. /etc/os-release 2>/dev/null && echo "$NAME $VERSION_ID" || echo "Linux")
    local hn;     hn=$(hostname)
    local total;  total=$(total_user)
    local expc;   expc=$(exp_count)
    local now;    now=$(date "+%H:%M  %d/%m/%Y")
    local theme;  theme=$(cat "$THEMEF" 2>/dev/null || echo "1")

    local svc_ic svc_txt svc_col
    if is_up; then svc_col="${LG}"; svc_ic="🟢"; svc_txt="RUNNING"
    else           svc_col="${LR}"; svc_ic="🔴"; svc_txt="STOPPED"; fi

    local bot_txt="${LR}Belum setup${NC}"
    [[ -f "$BOTF" ]] && { source "$BOTF" 2>/dev/null; bot_txt="${LG}@${BOT_NAME}${NC}"; }

    local brand="OGH-ZIV"
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; brand="${BRAND:-OGH-ZIV}"; }

    echo ""
    echo -e "  ${A1}┌─────────────────────────────────────────────────────────┐${NC}"
    printf  "  ${A1}│${NC}  ${BLD}${AL}✦ INFO VPS${NC}   ${DIM}%41s${NC}  ${A1}│${NC}\n" "$now"
    echo -e "  ${A1}├────────────────────────────┬────────────────────────────┤${NC}"
    printf  "  ${A1}│${NC}  ${DIM}Hostname${NC} : ${W}%-17s${NC}  ${A1}│${NC}  ${DIM}OS      ${NC}: ${W}%-17s${NC}  ${A1}│${NC}\n" "$hn" "$os"
    printf  "  ${A1}│${NC}  ${DIM}IP Publik${NC}: ${A3}%-17s${NC}  ${A1}│${NC}  ${DIM}Domain  ${NC}: ${W}%-17s${NC}  ${A1}│${NC}\n" "$ip" "$domain"
    printf  "  ${A1}│${NC}  ${DIM}Port VPN ${NC}: ${Y}%-17s${NC}  ${A1}│${NC}  ${DIM}Brand   ${NC}: ${AL}%-17s${NC}  ${A1}│${NC}\n" "$port" "$brand"
    echo -e "  ${A1}├────────────────────────────┴────────────────────────────┤${NC}"
    printf  "  ${A1}│${NC}  ${DIM}CPU${NC}: ${W}%s%%${NC}   ${DIM}RAM${NC}: ${W}%s/%sMB${NC}   ${DIM}Disk${NC}: ${W}%s/%s${NC}\n" "$cpu" "$ram_u" "$ram_t" "$du" "$dt"
    echo -e "  ${A1}├─────────────────────────────────────────────────────────┤${NC}"
    printf  "  ${A1}│${NC}  %s ZiVPN %b%-8s${NC}  ${DIM}Akun:${NC} ${W}%s${NC}  ${DIM}Exp:${NC} ${LR}%s${NC}  ${DIM}Bot:${NC} $bot_txt  ${DIM}Tema:${NC} ${AL}%s${NC}\n" \
        "$svc_ic" "$svc_col" "$svc_txt" "$total" "$expc" "${THEME_NAME}"
    echo -e "  ${A1}└─────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

show_header() {
    clear
    draw_logo
    draw_vps
}

# ════════════════════════════════════════════════════════════════
#  BINGKAI AKUN
# ════════════════════════════════════════════════════════════════
show_akun_box() {
    local u="$1" p="$2" domain="$3" port="$4" ql="$5" exp="$6" note="$7"
    local sisa=$(( ($(date -d "$exp" +%s 2>/dev/null || echo 0) - $(date +%s)) / 86400 ))
    local sisa_str; [[ $sisa -lt 0 ]] && sisa_str="${LR}Expired${NC}" || sisa_str="${LG}${sisa} hari lagi${NC}"
    local brand="OGH-ZIV"
    [[ -f "$STRF" ]] && { source "$STRF" 2>/dev/null; brand="${BRAND:-OGH-ZIV}"; }

    echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    printf  "  ${A1}║${NC}  ${IT}${AL}  ✦ %-52s${NC}  ${A1}║${NC}\n" "$brand — AKUN UDP VPN PREMIUM"
    echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Username  ${NC} ${A1}║${NC}  ${BLD}${W}%-41s${NC}  ${A1}║${NC}\n" "$u"
    printf  "  ${A1}║${NC} ${DIM} Password  ${NC} ${A1}║${NC}  ${BLD}${A3}%-41s${NC}  ${A1}║${NC}\n" "$p"
    echo -e "  ${A1}╠══════════════╬═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Host      ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$domain"
    printf  "  ${A1}║${NC} ${DIM} Port      ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$port"
    printf  "  ${A1}║${NC} ${DIM} Obfs      ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "zivpn"
    echo -e "  ${A1}╠══════════════╬═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Kuota     ${NC} ${A1}║${NC}  ${LG}%-41s${NC}  ${A1}║${NC}\n" "$ql"
    printf  "  ${A1}║${NC} ${DIM} Expired   ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$exp"
    printf  "  ${A1}║${NC} ${DIM} Sisa      ${NC} ${A1}║${NC}  $sisa_str\n"
    [[ "$note" != "-" ]] && printf "  ${A1}║${NC} ${DIM} Pembeli   ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$note"
    echo -e "  ${A1}╠══════════════╩═══════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${DIM}📱 Download ZiVPN → Play Store / App Store${NC}             ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${DIM}⚠  Jangan share akun ini ke orang lain!${NC}               ${A1}║${NC}"
    echo -e "  ${A1}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ════════════════════════════════════════════════════════════════
#  HELPERS
# ════════════════════════════════════════════════════════════════
_reload_pw() {
    [[ ! -f "$UDB" || ! -f "$CFG" ]] && return
    local pws=()
    while IFS='|' read -r _ pw _ _ _; do pws+=("\"$pw\""); done < "$UDB"
    local pwl; pwl=$(IFS=','; echo "${pws[*]}")
    python3 - <<PYEOF 2>/dev/null
import json
with open('$CFG') as f: c=json.load(f)
c['auth']['config']=[${pwl}]
with open('$CFG','w') as f: json.dump(c,f,indent=2)
PYEOF
    systemctl restart zivpn &>/dev/null
}

_tg_send() {
    [[ ! -f "$BOTF" ]] && return
    source "$BOTF" 2>/dev/null
    [[ -z "$BOT_TOKEN" || -z "$CHAT_ID" ]] && return
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" -d "text=$1" -d "parse_mode=HTML" &>/dev/null
}

_tg_raw() {
    local tok="$1" cid="$2" msg="$3"
    curl -s -X POST "https://api.telegram.org/bot${tok}/sendMessage" \
        -d "chat_id=${cid}" -d "text=${msg}" -d "parse_mode=HTML" &>/dev/null
}

# ════════════════════════════════════════════════════════════════
#  HELPER PANEL BUTTONS
# ════════════════════════════════════════════════════════════════
_top()  { echo -e "  ${A1}╔══════════════════════════════════════════════════════╗${NC}"; }
_bot()  { echo -e "  ${A1}╚══════════════════════════════════════════════════════╝${NC}"; }
_sep()  { echo -e "  ${A1}╠══════════════════════════════════════════════════════╣${NC}"; }
_sep2() { echo -e "  ${A1}╠══════════════════════╬═══════════════════════════════╣${NC}"; }
_row2() { echo -e "  ${A1}║${NC}                       ${A1}║${NC}                               ${A1}║${NC}"; }

# Tombol penuh 1 kolom
_btn() {
    printf "  ${A1}║${NC} %-54b ${A1}║${NC}\n" "$1"
}

# Tombol 2 kolom sejajar
_btn2() {
    printf "  ${A1}║${NC} %-38b ${A1}║${NC} %-39b ${A1}║${NC}\n" "$1" "$2"
}

# ════════════════════════════════════════════════════════════════
#  INSTALL
# ════════════════════════════════════════════════════════════════
do_install() {
    show_header
    _top
    _btn "  ${IT}${AL}🚀  INSTALL ZIVPN${NC}"
    _bot
    echo ""
    if [[ -f "$BIN" ]]; then
        warn "ZiVPN sudah terinstall."
        echo -ne "  Reinstall? [y/N]: "; read -r a
        [[ "$a" != [yY] ]] && return
    fi

    local sip; sip=$(get_ip)
    echo -ne "  ${A3}Domain / IP${NC}            : "; read -r inp_domain
    [[ -z "$inp_domain" ]] && inp_domain="$sip"
    echo -ne "  ${A3}Port${NC} [5667]             : "; read -r inp_port
    [[ -z "$inp_port" ]] && inp_port=5667
    echo -ne "  ${A3}Nama Brand / Toko${NC}       : "; read -r inp_brand
    [[ -z "$inp_brand" ]] && inp_brand="OGH-ZIV"
    echo -ne "  ${A3}Username Telegram Admin${NC}  : "; read -r inp_tg
    [[ -z "$inp_tg" ]] && inp_tg="-"

    echo ""
    echo -e "  ${A1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    inf "Memulai instalasi ${AL}OGH-ZIV Premium${NC}..."
    echo -e "  ${A1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    command -v apt-get &>/dev/null && apt-get update -qq &>/dev/null && \
        apt-get install -y -qq curl wget openssl python3 iptables &>/dev/null
    command -v yum &>/dev/null && yum install -y -q curl wget openssl python3 iptables &>/dev/null
    ok "Dependensi terpasang"

    mkdir -p "$DIR"; touch "$UDB" "$LOG"
    echo "$inp_domain" > "$DOMF"
    printf "BRAND=%s\nADMIN_TG=%s\n" "$inp_brand" "$inp_tg" > "$STRF"
    ok "Direktori & konfigurasi dibuat"

    inf "Mengunduh binary ZiVPN..."
    wget -q --show-progress -O "$BIN" "$BINARY_URL"
    [[ $? -ne 0 ]] && { err "Gagal download binary!"; pause; return 1; }
    chmod +x "$BIN"
    ok "Binary ZiVPN siap"

    inf "Membuat sertifikat SSL..."
    openssl req -x509 -nodes -newkey ec -pkeyopt ec_paramgen_curve:P-256 \
        -keyout "$DIR/zivpn.key" -out "$DIR/zivpn.crt" \
        -subj "/CN=$inp_domain" -days 3650 &>/dev/null
    ok "SSL Certificate (10 tahun) dibuat"

    cat > "$CFG" <<CFEOF
{
  "listen": ":${inp_port}",
  "cert": "/etc/zivpn/zivpn.crt",
  "key": "/etc/zivpn/zivpn.key",
  "obfs": "zivpn",
  "auth": {
    "mode": "passwords",
    "config": []
  }
}
CFEOF
    ok "config.json dibuat"

    cat > "$SVC" <<SVEOF
[Unit]
Description=OGH-ZIV UDP VPN Service
After=network.target

[Service]
Type=simple
User=root
ExecStart=$BIN server -c $CFG
Restart=on-failure
RestartSec=5s
LimitNOFILE=1048576
StandardOutput=append:$LOG
StandardError=append:$LOG

[Install]
WantedBy=multi-user.target
SVEOF

    systemctl daemon-reload
    systemctl enable zivpn &>/dev/null
    systemctl start zivpn
    ok "Service ZiVPN aktif & berjalan"

    command -v ufw &>/dev/null && ufw allow "$inp_port/udp" &>/dev/null && ufw allow "$inp_port/tcp" &>/dev/null
    iptables -I INPUT -p udp --dport "$inp_port" -j ACCEPT 2>/dev/null
    iptables -I INPUT -p tcp --dport "$inp_port" -j ACCEPT 2>/dev/null
    ok "Firewall port $inp_port dibuka"

    echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${A1}║${NC}  ${LG}${BLD}  ✦ OGH-ZIV PREMIUM BERHASIL DIINSTALL!${NC}              ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Domain    ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$inp_domain"
    printf  "  ${A1}║${NC} ${DIM} Port      ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$inp_port"
    printf  "  ${A1}║${NC} ${DIM} Brand     ${NC} ${A1}║${NC}  ${AL}%-41s${NC}  ${A1}║${NC}\n" "$inp_brand"
    echo -e "  ${A1}╚══════════════╩═══════════════════════════════════════════╝${NC}"
    pause
}

# ════════════════════════════════════════════════════════════════
#  USER FUNCTIONS
# ════════════════════════════════════════════════════════════════
u_add() {
    show_header
    _top; _btn "  ${IT}${AL}➕  TAMBAH AKUN BARU${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}               : "; read -r un
    [[ -z "$un" ]] && { err "Username kosong!"; pause; return; }
    grep -q "^${un}|" "$UDB" 2>/dev/null && { err "Username sudah ada!"; pause; return; }
    echo -ne "  ${A3}Password${NC} [auto]         : "; read -r up
    [[ -z "$up" ]] && up=$(rand_pass)
    echo -ne "  ${A3}Masa aktif (hari)${NC} [30]  : "; read -r ud
    [[ -z "$ud" ]] && ud=30
    local ue; ue=$(date -d "+${ud} days" +"%Y-%m-%d")
    echo -ne "  ${A3}Kuota GB${NC} (0=unlimited)  : "; read -r uq
    [[ -z "$uq" ]] && uq=0
    echo -ne "  ${A3}Catatan / Nama Pembeli${NC}  : "; read -r note
    [[ -z "$note" ]] && note="-"

    echo "${un}|${up}|${ue}|${uq}|${note}" >> "$UDB"
    _reload_pw

    local domain; domain=$(get_domain)
    local port;   port=$(get_port)
    local ql;     [[ "$uq" == "0" ]] && ql="Unlimited" || ql="${uq} GB"

    [[ -f "$STRF" ]] && source "$STRF" 2>/dev/null
    _tg_send "✅ <b>Akun Baru — ${BRAND:-OGH-ZIV}</b>
┌──────────────────────────
│ 👤 <b>Username</b> : <code>$un</code>
│ 🔑 <b>Password</b> : <code>$up</code>
├──────────────────────────
│ 🌐 <b>Host</b>     : <code>$domain</code>
│ 🔌 <b>Port</b>     : <code>$port</code>
│ 📡 <b>Obfs</b>     : <code>zivpn</code>
├──────────────────────────
│ 📦 <b>Kuota</b>    : $ql
│ 📅 <b>Expired</b>  : $ue
│ 📝 <b>Pembeli</b>  : $note
└──────────────────────────"

    show_akun_box "$un" "$up" "$domain" "$port" "$ql" "$ue" "$note"
    pause
}

u_list() {
    show_header
    _top; _btn "  ${IT}${AL}📋  LIST SEMUA AKUN${NC}"; _bot; echo ""
    [[ ! -s "$UDB" ]] && { warn "Belum ada akun terdaftar."; pause; return; }
    local today; today=$(date +"%Y-%m-%d"); local n=1
    echo -e "  ${A1}┌────┬──────────────────┬────────────┬────────────┬──────────┬─────────┐${NC}"
    printf  "  ${A1}│${NC}${BLD} %-2s ${A1}│${NC}${BLD} %-16s ${A1}│${NC}${BLD} %-10s ${A1}│${NC}${BLD} %-10s ${A1}│${NC}${BLD} %-8s ${A1}│${NC}${BLD} %-7s ${A1}│${NC}\n" \
        "#" "Username" "Password" "Expired" "Kuota" "Status"
    echo -e "  ${A1}├────┼──────────────────┼────────────┼────────────┼──────────┼─────────┤${NC}"
    while IFS='|' read -r u p e q _; do
        local sc sl
        [[ "$e" < "$today" ]] && sc="$LR" sl="EXPIRED" || sc="$LG" sl="AKTIF  "
        local ql; [[ "$q" == "0" ]] && ql="Unlim   " || ql="${q}GB     "
        printf "  ${A1}│${NC} ${DIM}%-2s${NC} ${A1}│${NC} ${W}%-16s${NC} ${A1}│${NC} ${A3}%-10s${NC} ${A1}│${NC} ${Y}%-10s${NC} ${A1}│${NC} %-8s ${A1}│${NC} ${sc}%-7s${NC} ${A1}│${NC}\n" \
            "$n" "$u" "$p" "$e" "$ql" "$sl"
        ((n++))
    done < "$UDB"
    echo -e "  ${A1}└────┴──────────────────┴────────────┴────────────┴──────────┴─────────┘${NC}"
    echo ""
    echo -e "  ${DIM}  Total: $((n-1)) akun  │  Expired: $(exp_count) akun${NC}"
    pause
}

u_info() {
    show_header
    _top; _btn "  ${IT}${AL}🔍  INFO DETAIL AKUN${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}: "; read -r un
    local ln; ln=$(grep "^${un}|" "$UDB" 2>/dev/null)
    [[ -z "$ln" ]] && { err "User tidak ditemukan!"; pause; return; }
    IFS='|' read -r u p e q note <<< "$ln"
    local domain; domain=$(get_domain)
    local port;   port=$(get_port)
    local ql;     [[ "$q" == "0" ]] && ql="Unlimited" || ql="${q} GB"
    show_akun_box "$u" "$p" "$domain" "$port" "$ql" "$e" "$note"
    pause
}

u_del() {
    show_header
    _top; _btn "  ${IT}${AL}🗑️   HAPUS AKUN${NC}"; _bot; echo ""
    [[ ! -s "$UDB" ]] && { warn "Tidak ada akun."; pause; return; }
    local n=1
    while IFS='|' read -r u _ e _ _; do
        printf "  ${DIM}%3s.${NC}  ${W}%-22s${NC}  ${DIM}exp: %s${NC}\n" "$n" "$u" "$e"; ((n++))
    done < "$UDB"
    echo ""
    echo -ne "  ${A3}Username yang dihapus${NC}: "; read -r du
    grep -q "^${du}|" "$UDB" 2>/dev/null || { err "User tidak ditemukan!"; pause; return; }
    sed -i "/^${du}|/d" "$UDB"
    _reload_pw
    _tg_send "🗑 <b>Akun Dihapus</b> : <code>$du</code>"
    ok "Akun '${W}$du${NC}' berhasil dihapus."
    pause
}

u_renew() {
    show_header
    _top; _btn "  ${IT}${AL}🔁  PERPANJANG AKUN${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}    : "; read -r ru
    grep -q "^${ru}|" "$UDB" 2>/dev/null || { err "User tidak ditemukan!"; pause; return; }
    echo -ne "  ${A3}Tambah hari${NC} : "; read -r rd; [[ -z "$rd" ]] && rd=30
    local ce; ce=$(grep "^${ru}|" "$UDB" | cut -d'|' -f3)
    local today; today=$(date +%Y-%m-%d)
    [[ "$ce" < "$today" ]] && ce="$today"
    local ne; ne=$(date -d "${ce} +${rd} days" +"%Y-%m-%d")
    sed -i "s/^\(${ru}|[^|]*|\)[^|]*/\1${ne}/" "$UDB"
    _tg_send "🔁 <b>Akun Diperpanjang</b>
👤 User     : <code>$ru</code>
📅 Expired  : <b>$ne</b>  (+${rd} hari)"
    echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${A1}║${NC}  ${LG}✔  Akun berhasil diperpanjang!${NC}                        ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Username  ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$ru"
    printf  "  ${A1}║${NC} ${DIM} Expired   ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$ne"
    printf  "  ${A1}║${NC} ${DIM} Tambahan  ${NC} ${A1}║${NC}  ${LG}+%-40s${NC}  ${A1}║${NC}\n" "${rd} hari"
    echo -e "  ${A1}╚══════════════╩═══════════════════════════════════════════╝${NC}"
    pause
}

u_chpass() {
    show_header
    _top; _btn "  ${IT}${AL}🔑  GANTI PASSWORD${NC}"; _bot; echo ""
    echo -ne "  ${A3}Username${NC}           : "; read -r pu
    grep -q "^${pu}|" "$UDB" 2>/dev/null || { err "User tidak ditemukan!"; pause; return; }
    echo -ne "  ${A3}Password baru${NC} [auto]: "; read -r pp
    [[ -z "$pp" ]] && pp=$(rand_pass)
    sed -i "s/^${pu}|[^|]*/${pu}|${pp}/" "$UDB"
    _reload_pw
    echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${A1}║${NC}  ${LG}✔  Password berhasil diubah!${NC}                          ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
    printf  "  ${A1}║${NC} ${DIM} Username  ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$pu"
    printf  "  ${A1}║${NC} ${DIM} Password  ${NC} ${A1}║${NC}  ${A3}%-41s${NC}  ${A1}║${NC}\n" "$pp"
    echo -e "  ${A1}╚══════════════╩═══════════════════════════════════════════╝${NC}"
    pause
}

u_trial() {
    show_header
    _top; _btn "  ${IT}${AL}🎁  BUAT AKUN TRIAL${NC}"; _bot; echo ""
    local tu="trial$(tr -dc 'a-z0-9' </dev/urandom | head -c 6)"
    local tp; tp=$(rand_pass)
    local te; te=$(date -d "+1 day" +"%Y-%m-%d")
    echo "${tu}|${tp}|${te}|1|TRIAL" >> "$UDB"
    _reload_pw
    local domain; domain=$(get_domain); local port; port=$(get_port)
    _tg_send "🎁 <b>Akun Trial Dibuat</b>
👤 User  : <code>$tu</code>
🔑 Pass  : <code>$tp</code>
📅 Exp   : $te  (1 hari / 1 GB)"
    show_akun_box "$tu" "$tp" "$domain" "$port" "1 GB" "$te" "TRIAL"
    pause
}

u_clean() {
    show_header
    _top; _btn "  ${IT}${AL}🧹  HAPUS AKUN EXPIRED${NC}"; _bot; echo ""
    local today; today=$(date +%Y-%m-%d); local cnt=0
    while IFS='|' read -r u _ e _ _; do
        if [[ "$e" < "$today" ]]; then
            sed -i "/^${u}|/d" "$UDB"
            ok "Dihapus: ${W}$u${NC}  ${DIM}(exp: $e)${NC}"; ((cnt++))
        fi
    done < <(cat "$UDB" 2>/dev/null)
    echo ""
    [[ $cnt -gt 0 ]] && { _reload_pw; ok "Total ${W}$cnt${NC} akun expired dihapus."; } \
                     || inf "Tidak ada akun expired."
    pause
}

# ════════════════════════════════════════════════════════════════
#  JUALAN
# ════════════════════════════════════════════════════════════════
t_akun() {
    show_header
    _top; _btn "  ${IT}${AL}📨  TEMPLATE PESAN AKUN${NC}"; _bot; echo ""
    [[ -f "$STRF" ]] && source "$STRF" 2>/dev/null
    echo -ne "  ${A3}Username${NC}: "; read -r tu
    local ln; ln=$(grep "^${tu}|" "$UDB" 2>/dev/null)
    [[ -z "$ln" ]] && { err "User tidak ditemukan!"; pause; return; }
    IFS='|' read -r u p e q note <<< "$ln"
    local domain; domain=$(get_domain); local port; port=$(get_port)
    local ql; [[ "$q" == "0" ]] && ql="Unlimited" || ql="${q} GB"
    show_akun_box "$u" "$p" "$domain" "$port" "$ql" "$e" "$note"
    pause
}

set_store() {
    show_header
    _top; _btn "  ${IT}${AL}⚙️   PENGATURAN TOKO${NC}"; _bot; echo ""
    [[ -f "$STRF" ]] && source "$STRF" 2>/dev/null
    echo -ne "  ${A3}Nama Brand${NC} [${BRAND:-OGH-ZIV}]   : "; read -r ib
    echo -ne "  ${A3}Username TG Admin${NC} [${ADMIN_TG:--}]: "; read -r it
    printf "BRAND=%s\nADMIN_TG=%s\n" "${ib:-${BRAND:-OGH-ZIV}}" "${it:-${ADMIN_TG:--}}" > "$STRF"
    ok "Pengaturan toko disimpan!"
    pause
}

# ════════════════════════════════════════════════════════════════
#  TELEGRAM BOT
# ════════════════════════════════════════════════════════════════
tg_setup() {
    show_header
    _top; _btn "  ${IT}${AL}🤖  SETUP BOT TELEGRAM${NC}"; _bot; echo ""
    inf "Buka ${A3}@BotFather${NC} di Telegram → ketik /newbot → salin TOKEN"
    inf "Kirim /start ke bot → buka URL:"
    echo -e "  ${DIM}     api.telegram.org/bot<TOKEN>/getUpdates${NC}"
    echo ""
    echo -ne "  ${A3}Bot Token${NC}     : "; read -r tok
    [[ -z "$tok" ]] && { err "Token kosong!"; pause; return; }
    echo -ne "  ${A3}Chat ID Admin${NC} : "; read -r cid
    [[ -z "$cid" ]] && { err "Chat ID kosong!"; pause; return; }
    local res; res=$(curl -s "https://api.telegram.org/bot${tok}/getMe")
    if echo "$res" | grep -q '"ok":true'; then
        local bname; bname=$(echo "$res" | python3 -c \
            "import sys,json;d=json.load(sys.stdin);print(d['result']['username'])" 2>/dev/null)
        printf "BOT_TOKEN=%s\nCHAT_ID=%s\nBOT_NAME=%s\n" "$tok" "$cid" "$bname" > "$BOTF"
        _tg_raw "$tok" "$cid" "✅ <b>OGH-ZIV Premium</b> bot terhubung ke server VPS!"
        echo ""
        echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${A1}║${NC}  ${LG}✔  Bot Telegram berhasil terhubung!${NC}                   ${A1}║${NC}"
        echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
        printf  "  ${A1}║${NC} ${DIM} Bot Name  ${NC} ${A1}║${NC}  ${W}@%-40s${NC}  ${A1}║${NC}\n" "$bname"
        printf  "  ${A1}║${NC} ${DIM} Chat ID   ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$cid"
        echo -e "  ${A1}╚══════════════╩═══════════════════════════════════════════╝${NC}"
    else
        err "Token tidak valid atau tidak bisa terhubung!"
    fi
    pause
}

tg_status() {
    show_header
    _top; _btn "  ${IT}${AL}📡  STATUS BOT TELEGRAM${NC}"; _bot; echo ""
    if [[ ! -f "$BOTF" ]]; then
        warn "Bot belum dikonfigurasi."
        echo -ne "  Setup sekarang? [y/N]: "; read -r a
        [[ "$a" == [yY] ]] && tg_setup; return
    fi
    source "$BOTF" 2>/dev/null
    local res; res=$(curl -s "https://api.telegram.org/bot${BOT_TOKEN}/getMe")
    if echo "$res" | grep -q '"ok":true'; then
        local fn; fn=$(echo "$res" | python3 -c \
            "import sys,json;d=json.load(sys.stdin);print(d['result']['first_name'])" 2>/dev/null)
        echo ""
        echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
        echo -e "  ${A1}║${NC}  ${LG}🟢  Bot Aktif & Terhubung${NC}                              ${A1}║${NC}"
        echo -e "  ${A1}╠══════════════╦═══════════════════════════════════════════╣${NC}"
        printf  "  ${A1}║${NC} ${DIM} Nama      ${NC} ${A1}║${NC}  ${W}%-41s${NC}  ${A1}║${NC}\n" "$fn"
        printf  "  ${A1}║${NC} ${DIM} Username  ${NC} ${A1}║${NC}  ${W}@%-40s${NC}  ${A1}║${NC}\n" "$BOT_NAME"
        printf  "  ${A1}║${NC} ${DIM} Chat ID   ${NC} ${A1}║${NC}  ${Y}%-41s${NC}  ${A1}║${NC}\n" "$CHAT_ID"
        echo -e "  ${A1}╚══════════════╩═══════════════════════════════════════════╝${NC}"
        echo ""
        echo -ne "  ${A3}Kirim pesan test?${NC} [y/N]: "; read -r ts
        [[ "$ts" == [yY] ]] && {
            _tg_send "🟢 <b>Test OGH-ZIV Premium</b> — Bot berjalan normal! ✅"
            ok "Pesan test dikirim ke Telegram!"
        }
    else
        err "Bot tidak dapat terhubung. Cek token!"
    fi
    pause
}

tg_kirim_akun() {
    show_header
    _top; _btn "  ${IT}${AL}📤  KIRIM AKUN KE TELEGRAM${NC}"; _bot; echo ""
    [[ ! -f "$BOTF" ]] && { err "Bot belum dikonfigurasi!"; pause; return; }
    source "$BOTF" 2>/dev/null
    [[ -f "$STRF" ]] && source "$STRF" 2>/dev/null
    echo -ne "  ${A3}Username akun${NC}    : "; read -r su
    local ln; ln=$(grep "^${su}|" "$UDB" 2>/dev/null)
    [[ -z "$ln" ]] && { err "User tidak ditemukan!"; pause; return; }
    IFS='|' read -r u p e q note <<< "$ln"
    echo -ne "  ${A3}Chat ID tujuan${NC} [$CHAT_ID]: "; read -r did
    [[ -z "$did" ]] && did="$CHAT_ID"
    local domain; domain=$(get_domain); local port; port=$(get_port)
    local ql; [[ "$q" == "0" ]] && ql="Unlimited" || ql="${q} GB"
    local sisa=$(( ($(date -d "$e" +%s 2>/dev/null || echo 0) - $(date +%s)) / 86400 ))
    local sisa_str; [[ $sisa -lt 0 ]] && sisa_str="Expired" || sisa_str="${sisa} hari lagi"
    local msg="🔒 <b>${BRAND:-OGH-ZIV} — Akun VPN UDP Premium</b>

┌────────────────────────────
│ 👤 <b>Username</b>  : <code>$u</code>
│ 🔑 <b>Password</b>  : <code>$p</code>
├────────────────────────────
│ 🌐 <b>Host</b>      : <code>$domain</code>
│ 🔌 <b>Port</b>      : <code>$port</code>
│ 📡 <b>Obfs</b>      : <code>zivpn</code>
├────────────────────────────
│ 📦 <b>Kuota</b>     : $ql
│ 📅 <b>Expired</b>   : $e
│ ⏳ <b>Sisa</b>      : $sisa_str
└────────────────────────────

📱 Download <b>ZiVPN</b> di Play Store / App Store
⚠️ Jangan share akun ini ke orang lain!"
    local r; r=$(curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${did}" -d "text=${msg}" -d "parse_mode=HTML")
    echo ""
    echo "$r" | grep -q '"ok":true' \
        && ok "Akun '${W}$u${NC}' berhasil dikirim ke Telegram!" \
        || err "Gagal kirim! Periksa Chat ID atau token."
    pause
}

tg_broadcast() {
    show_header
    _top; _btn "  ${IT}${AL}📢  BROADCAST PESAN${NC}"; _bot; echo ""
    [[ ! -f "$BOTF" ]] && { err "Bot belum dikonfigurasi!"; pause; return; }
    source "$BOTF" 2>/dev/null
    echo -e "  ${DIM}Ketik pesan. Ketik ${W}SELESAI${DIM} di baris baru untuk kirim.${NC}"
    echo ""
    local msg="" line
    while IFS= read -r line; do
        [[ "$line" == "SELESAI" ]] && break
        msg+="$line
"
    done
    [[ -z "$msg" ]] && { err "Pesan kosong!"; pause; return; }
    curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
        -d "chat_id=${CHAT_ID}" -d "text=${msg}" &>/dev/null
    ok "Broadcast berhasil dikirim!"
    pause
}

tg_guide() {
    show_header
    _top; _btn "  ${IT}${AL}📖  PANDUAN BUAT BOT TELEGRAM${NC}"; _bot; echo ""
    echo -e "  ${A1}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "  ${A1}║${NC}  ${Y}LANGKAH 1 — Buat Bot di BotFather${NC}                      ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${W}1.${NC} Buka Telegram → cari ${A3}@BotFather${NC}                       ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}2.${NC} Kirim perintah ${Y}/newbot${NC}                               ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}3.${NC} Masukkan nama bot → contoh: ${W}OGH ZIV VPN${NC}              ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}4.${NC} Masukkan username (akhiran ${Y}bot${NC})                       ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}5.${NC} Salin ${Y}TOKEN${NC} yang diberikan BotFather              ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${Y}LANGKAH 2 — Ambil Chat ID${NC}                               ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${W}1.${NC} Kirim ${Y}/start${NC} ke bot kamu di Telegram               ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}2.${NC} Buka: ${DIM}api.telegram.org/bot<TOKEN>/getUpdates${NC}       ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}3.${NC} Cari nilai ${Y}\"id\"${NC} di bagian ${Y}\"from\"${NC}                  ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${Y}LANGKAH 3 — Hubungkan ke OGH-ZIV${NC}                        ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${W}1.${NC} Menu Telegram → ${A3}[1] Setup / Konfigurasi Bot${NC}         ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}2.${NC} Masukkan Token dan Chat ID                           ${A1}║${NC}"
    echo -e "  ${A1}║${NC}  ${W}3.${NC} ${LG}✅ Selesai! Notifikasi otomatis aktif${NC}              ${A1}║${NC}"
    echo -e "  ${A1}╠══════════════════════════════════════════════════════════╣${NC}"
    echo -e "  ${A1}║${NC}  ${A3}https://t.me/BotFather${NC}                                   ${A1}║${NC}"
    echo -e "  ${A1}╚══════════════════════════════════════════════════════════╝${NC}"
    pause
}

# ════════════════════════════════════════════════════════════════
#  SERVICE
# ════════════════════════════════════════════════════════════════
svc_status() {
    show_header
    _top; _btn "  ${IT}${AL}🖥️   STATUS SERVICE${NC}"; _bot; echo ""
    systemctl status zivpn --no-pager -l
    pause
}

svc_bandwidth() {
    show_header
    _top; _btn "  ${IT}${AL}📊  BANDWIDTH / KONEKSI AKTIF${NC}"; _bot; echo ""
    local port; port=$(get_port)
    inf "Koneksi aktif ke port ${Y}$port${NC}:"
    echo ""
    ss -u -n -p 2>/dev/null | grep ":$port" || inf "Tidak ada koneksi UDP aktif saat ini."
    echo ""
    inf "Statistik network interface:"
    cat /proc/net/dev 2>/dev/null | awk 'NR>2{
        split($1,a,":");gsub(/[[:space:]]/,"",a[1]);
        if(a[1]!="lo") printf "  %-12s RX: %-12s TX: %s\n", a[1], $2, $10
    }' | head -5
    pause
}

svc_log() {
    show_header
    _top; _btn "  ${IT}${AL}📄  LOG ZIVPN${NC}"; _bot; echo ""
    [[ -f "$LOG" ]] && tail -60 "$LOG" || journalctl -u zivpn -n 60 --no-pager
    pause
}

svc_port() {
    show_header
    _top; _btn "  ${IT}${AL}🔧  GANTI PORT${NC}"; _bot; echo ""
    local cp; cp=$(get_port)
    echo -e "  Port saat ini : ${Y}$cp${NC}"
    echo -ne "  ${A3}Port baru${NC}     : "; read -r np
    [[ ! "$np" =~ ^[0-9]+$ || $np -lt 1 || $np -gt 65535 ]] && { err "Port tidak valid!"; pause; return; }
    sed -i "s/\"listen\": *\":${cp}\"/\"listen\": \":${np}\"/" "$CFG"
    command -v ufw &>/dev/null && { ufw delete allow "$cp/udp" &>/dev/null; ufw allow "$np/udp" &>/dev/null; }
    iptables -D INPUT -p udp --dport "$cp" -j ACCEPT 2>/dev/null
    iptables -I INPUT -p udp --dport "$np" -j ACCEPT 2>/dev/null
    systemctl restart zivpn
    ok "Port diubah: ${Y}$cp${NC} → ${LG}$np${NC}"
    pause
}

svc_backup() {
    show_header
    _top; _btn "  ${IT}${AL}💾  BACKUP DATA${NC}"; _bot; echo ""
    local bfile="/root/oghziv-backup-$(date +%Y%m%d-%H%M%S).tar.gz"
    inf "Membuat backup → ${W}$bfile${NC}"
    tar -czf "$bfile" "$DIR" 2>/dev/null
    [[ $? -eq 0 ]] && ok "Backup berhasil: ${W}$bfile${NC}" || err "Backup gagal!"
    pause
}

svc_restore() {
    show_header
    _top; _btn "  ${IT}${AL}♻️   RESTORE DATA${NC}"; _bot; echo ""
    echo -ne "  ${A3}Path file backup (.tar.gz)${NC}: "; read -r bpath
    [[ ! -f "$bpath" ]] && { err "File tidak ditemukan!"; pause; return; }
    warn "Restore akan menimpa semua data saat ini!"
    echo -ne "  Lanjutkan? [y/N]: "; read -r cf
    [[ "$cf" != [yY] ]] && { inf "Dibatalkan."; pause; return; }
    tar -xzf "$bpath" -C / 2>/dev/null
    _reload_pw
    ok "Restore berhasil!"
    pause
}

do_uninstall() {
    show_header
    _top; _btn "  ${IT}${AL}⚠️   UNINSTALL OGH-ZIV${NC}"; _bot; echo ""
    warn "Semua data user & konfigurasi akan DIHAPUS PERMANEN!"
    echo -ne "  ${LR}Ketik 'HAPUS' untuk konfirmasi${NC}: "; read -r cf
    [[ "$cf" != "HAPUS" ]] && { inf "Dibatalkan."; pause; return; }
    systemctl stop zivpn 2>/dev/null
    systemctl disable zivpn 2>/dev/null
    rm -f "$SVC" "$BIN"
    rm -rf "$DIR"
    systemctl daemon-reload
    ok "OGH-ZIV Premium berhasil diuninstall."
    pause
}

# ════════════════════════════════════════════════════════════════
#  SUB MENUS
# ════════════════════════════════════════════════════════════════
menu_akun() {
    while true; do
        show_header
        _top
        _btn "  ${IT}${AL}  👤  KELOLA AKUN USER${NC}"
        _sep
        _btn "  ${A2}[1]${NC}  ➕  Tambah Akun Baru"
        _sep
        _btn "  ${A2}[2]${NC}  📋  List Semua Akun"
        _sep
        _btn "  ${A2}[3]${NC}  🔍  Detail Akun"
        _sep
        _btn "  ${A2}[4]${NC}  🗑️   Hapus Akun"
        _sep
        _btn "  ${A2}[5]${NC}  🔁  Perpanjang Akun"
        _sep
        _btn "  ${A2}[6]${NC}  🔑  Ganti Password"
        _sep
        _btn "  ${A2}[7]${NC}  🎁  Buat Akun Trial"
        _sep
        _btn "  ${A2}[8]${NC}  🧹  Hapus Akun Expired"
        _sep
        _btn "  ${LR}[0]${NC}  ◀   Kembali"
        _bot
        echo ""
        echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in
            1) u_add ;;   2) u_list ;;  3) u_info ;;
            4) u_del ;;   5) u_renew ;; 6) u_chpass ;;
            7) u_trial ;; 8) u_clean ;;
            0) break ;;   *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

menu_jualan() {
    while true; do
        show_header
        [[ -f "$STRF" ]] && source "$STRF" 2>/dev/null
        _top
        _btn "  ${IT}${AL}  🛒  MENU JUALAN${NC}"
        _sep
        _btn "  ${A2}[1]${NC}  📨  Template Pesan Akun"
        _sep
        _btn "  ${A2}[2]${NC}  📤  Kirim Akun via Telegram"
        _sep
        _btn "  ${A2}[3]${NC}  ⚙️   Pengaturan Toko"
        _sep
        _btn "  ${LR}[0]${NC}  ◀   Kembali"
        _bot
        echo ""
        printf "  ${DIM}Brand: ${AL}%-20s${DIM}  TG: @%s${NC}\n" "${BRAND:-OGH-ZIV}" "${ADMIN_TG:--}"
        echo ""
        echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in
            1) t_akun ;; 2) tg_kirim_akun ;; 3) set_store ;;
            0) break ;; *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

menu_telegram() {
    while true; do
        show_header
        local bstat="${LR}Belum dikonfigurasi${NC}"
        [[ -f "$BOTF" ]] && { source "$BOTF" 2>/dev/null; bstat="${LG}@${BOT_NAME}${NC}"; }
        _top
        _btn "  ${IT}${AL}  🤖  TELEGRAM BOT${NC}"
        _sep
        printf "  ${A1}║${NC}  ${DIM}Status :${NC} $bstat\n"
        _sep
        _btn "  ${A2}[1]${NC}  🔧  Setup / Konfigurasi Bot"
        _sep
        _btn "  ${A2}[2]${NC}  📡  Cek Status Bot"
        _sep
        _btn "  ${A2}[3]${NC}  📤  Kirim Akun ke Telegram"
        _sep
        _btn "  ${A2}[4]${NC}  📢  Broadcast Pesan"
        _sep
        _btn "  ${A2}[5]${NC}  📖  Panduan Buat Bot"
        _sep
        _btn "  ${LR}[0]${NC}  ◀   Kembali"
        _bot
        echo ""
        echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in
            1) tg_setup ;; 2) tg_status ;;    3) tg_kirim_akun ;;
            4) tg_broadcast ;; 5) tg_guide ;;
            0) break ;; *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

menu_service() {
    while true; do
        show_header
        _top
        _btn "  ${IT}${AL}  ⚙️   MANAJEMEN SERVICE${NC}"
        _sep
        _btn "  ${A2}[1]${NC}  🖥️   Status Service"
        _sep
        _btn "  ${A2}[2]${NC}  ▶️   Start ZiVPN"
        _sep
        _btn "  ${A2}[3]${NC}  ⏹️   Stop ZiVPN"
        _sep
        _btn "  ${A2}[4]${NC}  🔄  Restart ZiVPN"
        _sep
        _btn "  ${A2}[5]${NC}  📄  Lihat Log"
        _sep
        _btn "  ${A2}[6]${NC}  🔧  Ganti Port"
        _sep
        _btn "  ${A2}[7]${NC}  💾  Backup Data"
        _sep
        _btn "  ${A2}[8]${NC}  ♻️   Restore Data"
        _sep
        _btn "  ${LR}[0]${NC}  ◀   Kembali"
        _bot
        echo ""
        echo -ne "  ${A1}›${NC} "; read -r ch
        case $ch in
            1) svc_status ;;
            2) systemctl start zivpn;   ok "ZiVPN dijalankan.";  pause ;;
            3) systemctl stop zivpn;    ok "ZiVPN dihentikan.";  pause ;;
            4) systemctl restart zivpn; sleep 1
               is_up && ok "Restart berhasil!" || err "Gagal restart!"; pause ;;
            5) svc_log ;;  6) svc_port ;;
            7) svc_backup ;; 8) svc_restore ;;
            0) break ;; *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════════
#  MENU UTAMA
# ════════════════════════════════════════════════════════════════
main_menu() {
    while true; do
        show_header
        _top
        _btn "  ${IT}${AL}  ✦  OGH-ZIV PREMIUM PANEL  ✦${NC}"
        _sep
        _btn "  ${A2}[1]${NC}  👤  Kelola Akun User"
        _sep
        _btn "  ${A2}[2]${NC}  ⚙️   Manajemen Service"
        _sep
        _btn "  ${A2}[3]${NC}  🤖  Telegram Bot"
        _sep
        _btn "  ${A2}[4]${NC}  🛒  Menu Jualan"
        _sep
        _btn "  ${A2}[5]${NC}  📊  Bandwidth & Koneksi"
        _sep
        _btn "  ${A2}[6]${NC}  🔄  Restart Service"
        _sep
        _btn "  ${A2}[7]${NC}  🚀  Install ZiVPN"
        _sep
        _btn "  ${A2}[8]${NC}  🎨  Ganti Tema Warna  ${DIM}[${THEME_NAME}]${NC}"
        _sep
        _btn "  ${LR}[9]${NC}  🗑️   Uninstall ZiVPN"
        _sep
        _btn "  ${LR}[0]${NC}  ❌  Keluar"
        _bot
        echo ""
        echo -ne "  ${A1}›${NC} "
        read -r ch
        case ${ch,,} in
            1) menu_akun ;;
            2) menu_service ;;
            3) menu_telegram ;;
            4) menu_jualan ;;
            5) svc_bandwidth ;;
            6) systemctl restart zivpn; sleep 1
               is_up && ok "Service berhasil direstart!" || err "Gagal restart!"; pause ;;
            7) do_install ;;
            8) menu_tema ;;
            9) do_uninstall ;;
            0) echo -e "\n  ${IT}${AL}Sampai jumpa! — OGH-ZIV Premium${NC}\n"; exit 0 ;;
            *) warn "Pilihan tidak valid!"; sleep 1 ;;
        esac
    done
}

# ════════════════════════════════════════════════════════════════
#  SETUP AUTO COMMAND 'menu' & 'zivpn'
# ════════════════════════════════════════════════════════════════
setup_menu_cmd() {
    local sp; sp=$(realpath "$0" 2>/dev/null || echo "$0")

    # Salin script ke lokasi permanen
    if [[ "$sp" != "/usr/local/bin/ogh-ziv" ]]; then
        cp "$0" /usr/local/bin/ogh-ziv 2>/dev/null
        chmod +x /usr/local/bin/ogh-ziv 2>/dev/null
    fi

    # Buat symlink /usr/local/bin/zivpn → ogh-ziv
    # agar bisa dipanggil langsung dengan: zivpn
    if [[ ! -f "/usr/local/bin/zivpn" ]] || \
       [[ "$(readlink -f /usr/local/bin/zivpn 2>/dev/null)" != "/usr/local/bin/ogh-ziv" ]]; then
        ln -sf /usr/local/bin/ogh-ziv /usr/local/bin/zivpn 2>/dev/null
    fi

    # Tambah alias 'menu' dan 'zivpn' ke .bashrc
    grep -q "alias menu=" ~/.bashrc 2>/dev/null || \
        echo "alias menu='bash /usr/local/bin/ogh-ziv'" >> ~/.bashrc
    grep -q "alias zivpn=" ~/.bashrc 2>/dev/null || \
        echo "alias zivpn='bash /usr/local/bin/ogh-ziv'" >> ~/.bashrc
}

# ════════════════════════════════════════════════════════════════
#  MAIN
# ════════════════════════════════════════════════════════════════
check_root
mkdir -p "$DIR"
load_theme
setup_menu_cmd 2>/dev/null
main_menu
