#!/usr/bin/env bash
set -euo pipefail

function globais(){

if [[ $EUID -ne 0 ]]; then
  echo "Run as root."
  exit 1
fi

version="1.0.0"
WHITE="$(tput setaf 7)"
CYAN="$(tput setaf 6)"
MAGENTA="$(tput setaf 5)"
YELLOW="$(tput setaf 3)"
GREEN="$(tput setaf 2)"
BLUE="$(tput setaf 4)"
RED="$(tput setaf 1)"
NORMAL="$(tput sgr0)"
BOLD="$(tput bold)"

RED2='\033[0;31m'
GREEN2='\033[0;32m'
YELLOW2='\033[1;33m'
NC='\033[0m'


BOOTUP=color
RES_COL=60
MOVE_TO_COL="echo -en \\033[${RES_COL}G"
SETCOLOR_SUCCESS="echo -en \\033[1;32m"
SETCOLOR_FAILURE="echo -en \\033[1;31m"
SETCOLOR_WARNING="echo -en \\033[1;33m"
SETCOLOR_NORMAL="echo -en \\033[0;39m"

tput init
}
function titulo(){
  clear
  tput init
  titulo=$1
  if [[ $titulo = *[[:digit:]]* ]]; then
    sleep "$titulo"
    titulo=$2
  fi
  echo -e "\n${BLUE}${titulo}${NORMAL}"
  tput init
}
log_info() {
    echo -e "${GREEN2}[INFO]${NC} $1"
}
echo_success() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_SUCCESS
    echo -n $"  OK  "
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 0
}
echo_failure() {
    [ "$BOOTUP" = "color" ] && $MOVE_TO_COL
    echo -n "["
    [ "$BOOTUP" = "color" ] && $SETCOLOR_FAILURE
    echo -n $"FAILED"
    [ "$BOOTUP" = "color" ] && $SETCOLOR_NORMAL
    echo -n "]"
    echo -ne "\r"
    return 1
}
step() {
    echo -n "$@"
    STEP_OK=0
    [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$
}
try() {
    local BG=
    [[ $1 == -b ]] && { BG=1; shift; }
    [[ $1 == -- ]] && {       shift; }
    if [[ -z $BG ]]; then
        "$@"
    else
        "$@" &
    fi
    local EXIT_CODE=$?
    if [[ $EXIT_CODE -ne 0 ]]; then
        STEP_OK=$EXIT_CODE
        [[ -w /tmp ]] && echo $STEP_OK > /tmp/step.$$

        if [[ -n $LOG_STEPS ]]; then
            local FILE=$(readlink -m "${BASH_SOURCE[1]}")
            local LINE=${BASH_LINENO[0]}

            echo "$FILE: line $LINE: Command \`$*' failed with exit code $EXIT_CODE." >> "$LOG_STEPS"
        fi
    fi

    return $EXIT_CODE
}
next() {
    [[ -f /tmp/step.$$ ]] && { STEP_OK=$(< /tmp/step.$$); rm -f /tmp/step.$$; }
    [[ $STEP_OK -eq 0 ]]  && echo_success || echo_failure
    echo

    return $STEP_OK
}

function esperar2(){
  CINZA="$(tput setaf 8)"
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  CHECK_SYMBOL='\u2713'
  X_SYMBOL='\u2A2F'
  local done=${3:-'Atualizado'}
  local msg=$2
  eval $1 >/tmp/execute-and-wait.log 2>&1 &
  pid=$!
  delay=0.05
  frames=('\u280B' '\u2819' '\u2839' '\u2838' '\u283C' '\u2834' '\u2826' '\u2827' '\u2807' '\u280F')
  echo "$pid" >"/tmp/.spinner.pid"
  tput civis
  index=0
  framesCount=${#frames[@]}
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    printf "${YELLOW}${frames[$index]}${NC} ${GREEN}${msg}${NC}"
    let index=index+1
    if [ "$index" -ge "$framesCount" ]; then
      index=0
    fi
    printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    sleep $delay
  done
  echo -e "\b\\r${CINZA}${done}   "
  #echo -e ""
  read -n 1 -s -p "${CINZA}Press any key to continue"
  tput init
  #clear
}
function esperar3(){
  CINZA="$(tput setaf 8)"
  CHECK_MARK="\033[0;32m\xE2\x9C\x94\033[0m"
  CHECK_SYMBOL='\u2713'
  X_SYMBOL='\u2A2F'
  local done=${3:-'X'}
  local msg=$2
  eval $1 >/tmp/execute-and-wait.log 2>&1 &
  pid=$!
  delay=0.05
  frames=('\u280B' '\u2819' '\u2839' '\u2838' '\u283C' '\u2834' '\u2826' '\u2827' '\u2807' '\u280F')
  echo "$pid" >"/tmp/.spinner.pid"
  tput civis
  index=0
  framesCount=${#frames[@]}
  while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
    echo -ne "${RED}${frames[$index]}${NC} ${BLUE}${msg}${NC}"
    let index=index+1
    if [ "$index" -ge "$framesCount" ]; then
      index=0
    fi
    echo -ne "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
    sleep $delay
  done
  echo -ne "\b\\r${CHECK_MARK}${GREEN} ${done}"
}


function sslcert(){

    DOMAIN="cert.ospro.pt"
    BASE_DIR="/etc/letsencrypt/live"

    PUBLIC_CERT='-----BEGIN CERTIFICATE-----
MIIDizCCAxCgAwIBAgISBtkOMDbmEctjzDFjvp2OK556MAoGCCqGSM49BAMDMDMx
CzAJBgNVBAYTAlVTMRYwFAYDVQQKEw1MZXQncyBFbmNyeXB0MQwwCgYDVQQDEwNZ
RTIwHhcNMjYwNTMwMTYwNDU2WhcNMjYwODI4MTYwNDU1WjAYMRYwFAYDVQQDEw1j
ZXJ0Lm9zcHJvLnB0MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEMu2GdwXmIEx3
4uGEK48n8ThKAt80pOgPyQth/NL3Wiea1n0uc8ImbAMFynlPKPwuYZZcPZCQfFWn
XIOTviHfjqOCAh0wggIZMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEF
BQcDATAMBgNVHRMBAf8EAjAAMB0GA1UdDgQWBBQck1i2wln6YtghxrQkKupz06wE
9DAfBgNVHSMEGDAWgBS5WfKOzyLwhtM3SP92FBi6gthVhzAzBggrBgEFBQcBAQQn
MCUwIwYIKwYBBQUHMAKGF2h0dHA6Ly95ZTIuaS5sZW5jci5vcmcvMBgGA1UdEQQR
MA+CDWNlcnQub3Nwcm8ucHQwEwYDVR0gBAwwCjAIBgZngQwBAgEwLwYDVR0fBCgw
JjAkoCKgIIYeaHR0cDovL3llMi5jLmxlbmNyLm9yZy8xMjMuY3JsMIIBDQYKKwYB
BAHWeQIEAgSB/gSB+wD5AHcAlE5Dh/rswe+B8xkkJqgYZQHH0184AgE/cmd9VTcu
GdgAAAGeedcx2QAABAMASDBGAiEA1iDKy7hNcqBkAexYOSxlABaiMJjdvrwt28QT
hIyaidkCIQDScbotjdb9f+dTytV+xgDmp32YqPzcoueeQt0YcZXZFwB+ACbjZG5Y
aSEjvDQ/RyQ1mzeSzSRaiNgV05Mz/ZkYq0cjAAABnnnXMYQACAAABQAXHEj7BAMA
RzBFAiEAuwvD//yGf6Y9nICdhyqStkC2twXHe1YkXce/uK81hpICIESVIAeqeKjX
nQov1qYeLEDh5imMBeZ2044AWkP5JB7fMAoGCCqGSM49BAMDA2kAMGYCMQDKKEFc
S0xDESkMG4c1Kxhq5eR4kQsOc7GZn/qT/BItdm1ZglmyuuHLsnZc1NAmY5kCMQD4
eyifUkOtTl/l+68yWfls02y1EXH+dJVG2bgaihDvOi04WQMt55l/6ebQhPzzGVQ=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIICjDCCAhGgAwIBAgIQTfOxXdbAeExQfNN7WObxFTAKBggqhkjOPQQDAzAuMQsw
CQYDVQQGEwJVUzENMAsGA1UEChMESVNSRzEQMA4GA1UEAxMHUm9vdCBZRTAeFw0y
NTA5MDMwMDAwMDBaFw0yODA5MDIyMzU5NTlaMDMxCzAJBgNVBAYTAlVTMRYwFAYD
VQQKEw1MZXQncyBFbmNyeXB0MQwwCgYDVQQDEwNZRTIwdjAQBgcqhkjOPQIBBgUr
gQQAIgNiAARxmrQzkdbEEL3MqXt3dJQttYc47axkdDTHud5TPqM2z5uSD5cmk0Wr
HlWXvnlvqBLqiB34kluxIbmMyAiq3/YD6e80/vV259K8XQIdjFXloYOa0mIU71f7
HQ09PvYDlw+jge4wgeswDgYDVR0PAQH/BAQDAgGGMBMGA1UdJQQMMAoGCCsGAQUF
BwMBMBIGA1UdEwEB/wQIMAYBAf8CAQAwHQYDVR0OBBYEFLlZ8o7PIvCG0zdI/3YU
GLqC2FWHMB8GA1UdIwQYMBaAFKPIJlqOoUzQNWP8myPIOq5W809WMDIGCCsGAQUF
BwEBBCYwJDAiBggrBgEFBQcwAoYWaHR0cDovL3llLmkubGVuY3Iub3JnLzATBgNV
HSAEDDAKMAgGBmeBDAECATAnBgNVHR8EIDAeMBygGqAYhhZodHRwOi8veWUuYy5s
ZW5jci5vcmcvMAoGCCqGSM49BAMDA2kAMGYCMQDIcnw5dcZLN9ffynXnnkLD/itS
JEycJPb3sRkzeqBowup7vOsAwaqoCnNn/jh9wycCMQCJM6CPlaOC4pQYYbJtVPYb
DKrIb2EKk5NpOpE6/XttQYZV/3gilB9l+Cc/DOVwmyg=
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIICpjCCAiugAwIBAgIRAIchZfw0tuX7qK3Vs3BftTowCgYIKoZIzj0EAwMwTzEL
MAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2VhcmNo
IEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDIwHhcNMjYwNTEzMDAwMDAwWhcN
MzIwOTAyMjM1OTU5WjAuMQswCQYDVQQGEwJVUzENMAsGA1UEChMESVNSRzEQMA4G
A1UEAxMHUm9vdCBZRTB2MBAGByqGSM49AgEGBSuBBAAiA2IABDwS/6vhrcVqcbBo
+wgdI3fwn9x7DNJJOY/lTOti0vkwuRN87RhEhTH17E7XyFjWsPYhIPt/wzOqxTd2
b+4ZJNy9ID04YywF9U5zasDVyGSNErVNtz8uSGh5izW87j77GaOB6zCB6DAOBgNV
HQ8BAf8EBAMCAQYwEwYDVR0lBAwwCgYIKwYBBQUHAwEwDwYDVR0TAQH/BAUwAwEB
/zAdBgNVHQ4EFgQUo8gmWo6hTNA1Y/ybI8g6rlbzT1YwHwYDVR0jBBgwFoAUfEKW
rt5LSDv6kviejM9ti6lyN5UwMgYIKwYBBQUHAQEEJjAkMCIGCCsGAQUFBzAChhZo
dHRwOi8veDIuaS5sZW5jci5vcmcvMBMGA1UdIAQMMAowCAYGZ4EMAQIBMCcGA1Ud
HwQgMB4wHKAaoBiGFmh0dHA6Ly94Mi5jLmxlbmNyLm9yZy8wCgYIKoZIzj0EAwMD
aQAwZgIxAMU19WCtmxVND8UHBZRoma49Z7jPs64Dma0eTu1OChVbB/2J7GV3nvYK
Ax54uk1G9QIxAO0miLVJu8PLNiXXXkiE/gsK3CTRTF/aeo4bMX42Zw40csRU6AC2
6hSW1/IWaas6dg==
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
MIIEcDCCAligAwIBAgIQbI8dxyfHEX97r4U6yYD5zTANBgkqhkiG9w0BAQsFADBP
MQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJuZXQgU2VjdXJpdHkgUmVzZWFy
Y2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBYMTAeFw0yNjA1MTMwMDAwMDBa
Fw0zMjA5MDIyMzU5NTlaME8xCzAJBgNVBAYTAlVTMSkwJwYDVQQKEyBJbnRlcm5l
dCBTZWN1cml0eSBSZXNlYXJjaCBHcm91cDEVMBMGA1UEAxMMSVNSRyBSb290IFgy
MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEzZvVn4CDCuwJSvMWSj5cz3es3mcFDR0H
ttwW+1qLFNvicWDEukWVEYmO6gbf9yoWHKS5xcUy4APgHoIYOIvXRdgKam7mAHf7
AlF9ItgKbppbd9/w+kHsOdx1ymgHDB/qo4H1MIHyMA4GA1UdDwEB/wQEAwIBBjAd
BgNVHSUEFjAUBggrBgEFBQcDAQYIKwYBBQUHAwIwDwYDVR0TAQH/BAUwAwEB/zAd
BgNVHQ4EFgQUfEKWrt5LSDv6kviejM9ti6lyN5UwHwYDVR0jBBgwFoAUebRZ5nu2
5eQBc4AIiMgaWPbpm24wMgYIKwYBBQUHAQEEJjAkMCIGCCsGAQUFBzAChhZodHRw
Oi8veDEuaS5sZW5jci5vcmcvMBMGA1UdIAQMMAowCAYGZ4EMAQIBMCcGA1UdHwQg
MB4wHKAaoBiGFmh0dHA6Ly94MS5jLmxlbmNyLm9yZy8wDQYJKoZIhvcNAQELBQAD
ggIBAD2/e9frmMxNpCV03qUHegg+MV2wz9644YoXdqtH8RyWYcBO7xfjjGEXdU1e
/o0OkEFiynUCOSIk/vLLo7ttz6CPAeNlWfC0XNkoGeWgK6jjXvozBaGuGH5n0Ufo
shMeWTuURqNN5G00sSXDTBrpp2+mgvdZQjb8K11TYMA25QA+YHNfbIEL0BniAhKS
2gsnJjSzrdZLI+EZ7SEyqdR2rkjd1KutLDU+n3TFyxjniZVGur4YlhMP3mY/dV95
IruAkkjOZier6hGBdEgZXXvaCz9u9iVEadsIE75pAGL8oHV5vxdARDiotRpul1IN
/UZwzAbrfUFcw1HkAcYD/mlZfnQ2ieCF2MS7j3Vhv7JPDKp45fmykmzYNSrumRW0
upFFKDBOoF7hsOb7oLyHS+Uft6jOUfOrogj8YUx38hKb2K20r42OgsSdDdxdeYWc
MS3Sb6mwJeSZEYxJ2gaXnDSPaKhhrNkYwljyVQyr4Nq+MEJytXNTnHqaAcrNwZlV
pcJL1KBnMrMjP7eanvUwL3FYj3cF17jtboLt7gLoi4+2rWZFvn+w54jmd/FIuhhZ
cEaU/wvU6BUNMtcVquVGHp7itQeDth5j+XL3j4WJ2SABwzUl6OeYdgpIt/ITZa+p
TT0mQ/r5XyA4MEAiabn7XJjvCERlF2dcn2wqJw+CreTkkQ2R
-----END CERTIFICATE-----'

    mkdir -p "$BASE_DIR"
    
    printf '%s\n' "$PUBLIC_CERT" > "$BASE_DIR/${DOMAIN}_fullchain.pem"
    sleep 1
    esperar3 "sleep 2" "Adionando " "File public adicionado"

}
function sslkey(){

    DOMAIN="cert.ospro.pt"
    BASE_DIR="/etc/letsencrypt/live"

    PRIVATE_KEY='-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgyPp3PIhOxxahpm4u
lqapJWJqQ/GgFxY7YbBCngkqWmyhRANCAAQy7YZ3BeYgTHfi4YQrjyfxOEoC3zSk
6A/JC2H80vdaJ5rWfS5zwiZsAwXKeU8o/C5hllw9kJB8Vadcg5O+Id+O
-----END PRIVATE KEY-----'


    mkdir -p "$BASE_DIR"

    printf '%s\n' "$PRIVATE_KEY" > "$BASE_DIR/${DOMAIN}_privkey.pem"
    sleep 1
    esperar3 "sleep 2" "Adionando private " "File private adicionado" 

}
function esperar_spinner(){
  local cmd=$1
  local msg=$2
  local done_msg=$3
  
  eval "$cmd" >/tmp/cmd.log 2>&1 &
  local pid=$!
  local delay=0.1
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  
  tput civis # Hide cursor
  while kill -0 $pid 2>/dev/null; do
    for frame in "${frames[@]}"; do
      printf "\r${YELLOW}%s${NC} ${BLUE}%s${NC}" "$frame" "$msg"
      sleep $delay
    done
  done
  tput cnorm # Show cursor
  printf "\r${CINZA}%s${NC}\n" "$done_msg"
}
# --- Functions ---
globais

main() {
    
    titulo "Cloudflare ssl..."
    log_info "Adicionar certificados public e private"
	step "X"
        #try sslcert
        try esperar3 "sslcert" "Adionando " "File public adicionado"
	next
    step "X"
        #try sslkey
	   try esperar3 "sslkey" "Adionando private " "File private adicionado" 
    next
    
    #esperar2 "sleep 1" "Aguarde..." "${WHITE}Atualizado!"
        
    esperar_spinner "sleep 2" "Finalizing installation..." "SSL Successfully Installed!"
    echo -e "\n${WHITE}Certificates located at: /etc/letsencrypt/live/${NC}"
        
}

main "$@"
