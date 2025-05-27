#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================
#	System Required: CentOS 7/8,Debian/ubuntu,oraclelinux
#	Description: 颜sir WhatsApp 机器人
#	Version: 3.2
#	Author: 颜sir
#	更新内容及反馈:  
#=================================================

# RED='\033[0;31m'
# GREEN='\033[0;32m'
# YELLOW='\033[0;33m'
# SKYBLUE='\033[0;36m'
# PLAIN='\033[0m'
# 颜色定义


sh_ver="3.5"
github="raw.githubusercontent.com/yansircc/WhatsApp/master"

  # 获取当前IP地址，设置超时为3秒
current_ip=$(curl -s --max-time 3 https://api.ipify.org)
  
  
imgurl=""
headurl=""
github_network=1

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Green_font_prefix}[注意]${Font_color_suffix}"

# 检查当前用户是否为 root 用户
if [ "$EUID" -ne 0 ]; then
  echo "请使用 root 用户身份运行此脚本"
  exit
fi

# 检查github网络
check_github() {
  # 检测域名的可访问性函数
  check_domain() {
    local domain="$1"
    if ! curl --max-time 5 --head --silent --fail "$domain" >/dev/null; then
      echo -e "${Error}无法访问 $domain，请检查网络或者本地DNS 或者访问频率过快而受限"
      github_network=0
    fi
  }

  # 检测所有域名的可访问性
  check_domain "https://raw.githubusercontent.com"
  check_domain "https://api.github.com"
  check_domain "https://github.com"

  if [ "$github_network" -eq 0 ]; then
    echo -e "${Error}github网络访问受限，将影响内核的安装以及脚本的检查，5秒后继续运行脚本"
    sleep 5
  else
    # 所有域名均可访问，打印成功提示
    echo -e "${Green_font_prefix}github可访问${Font_color_suffix}，继续执行脚本..."
  fi
}



#检查磁盘空间
check_disk_space() {
    # 检查是否存在 bc 命令
    if ! command -v bc &> /dev/null; then
        echo "安装 bc 命令..."
        # 检查系统类型并安装相应的 bc 包
        if [ -f /etc/redhat-release ]; then
            yum install -y bc
        elif [ -f /etc/debian_version ]; then
            apt-get update
            apt-get install -y bc
        else
            echo "无法确定系统类型，请手动安装 bc 命令。"
            return 1
        fi
    fi

    # 获取当前磁盘剩余空间
    available_space=$(df -h / | awk 'NR==2 {print $4}')

    # 移除单位字符，例如"GB"，并将剩余空间转换为数字
    available_space=$(echo $available_space | sed 's/G//')

    # 如果剩余空间小于等于0，则输出警告信息
    if [ $(echo "$available_space <= 0" | bc) -eq 1 ]; then
        echo "警告：磁盘空间已用尽，请勿重启，先清理空间。建议先卸载刚才安装的内核来释放空间，仅供参考。"
    else
        echo -e "当前磁盘剩余空间：${Green_font_prefix}$available_space GB${Font_color_suffix}"
    fi
}



break_end() {
      echo -e "\033[0;32m操作完成\033[0m"
      echo "按任意键继续..."
      read -n 1 -s -r -p ""
      echo ""
      clear
}

#脚本
Update_Shell() {
  local shell_file
  shell_file="$(readlink -f "$0")"
  local shell_url="https://raw.githubusercontent.com/jerryrat/whatsapp-docker-compose-file/main/all-in-one.sh"

  # 下载最新版本的脚本
  wget -O "/tmp/all-in-one.sh" "$shell_url" &>/dev/null

  # 比较本地和远程脚本的 md5 值
  local md5_local
  local md5_remote
  md5_local="$(md5sum "$shell_file" | awk '{print $1}')"
  md5_remote="$(md5sum /tmp/all-in-one.sh | awk '{print $1}')"

  if [ "$md5_local" != "$md5_remote" ]; then
    # 替换本地脚本文件
    cp "/tmp/all-in-one.sh" "$shell_file"
    chmod +x "$shell_file"

    echo "脚本已更新，请重新运行。按键盘任意按键返回主菜单。"
    #exit 0
  else
    echo "脚本是最新版本，无需更新。按键盘任意按键返回主菜单。"
  fi
  echo
  ./all-in-one.sh
}


#开始菜单
start_menu() {
  #clear 修复闪屏
  echo && echo -e " 颜sir WhatsApp 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}] 
 ${Green_font_prefix}1.${Font_color_suffix} 几乎用不着不用选    --颜Sir更新了脚本后选1自动更新vps本地脚本
 ${Green_font_prefix}2.${Font_color_suffix} ${YELLOW}安装docker          --全系系统请务必安装docker环境，可以选择查看是否已经安装${NC}
 ${Green_font_prefix}3.${Font_color_suffix} ${YELLOW}安装WhatsApp服务    --全自动安装服务${NC}
 ${Green_font_prefix}4.${Font_color_suffix} ${YELLOW}卸载Whatsapp服务   --清空服务器从0开始配置，出了问题选这个卸载重装${NC}
 ${Green_font_prefix}5.${Font_color_suffix} ${YELLOW}更新WhatsApp服务    --保留数据库，只更新聊天服务插件${NC}
 ${Green_font_prefix}6.${Font_color_suffix} ${YELLOW}查看WhatsApp设置密码 --请勿泄露IP${NC}
 ${Green_font_prefix}7.${Font_color_suffix} ${YELLOW}重启WhatsApp服务    --遇到设置网页无法显示或者机器人无法工作 可以先尝试该选项${NC}
 
  ——————————————以下为二次开发内容 无需求勿安装————————————————————————
 ${Green_font_prefix}8.${Font_color_suffix} 添加APIkey          --为WhatsApp机器人添加API-KEY 发消息用 二开功能
 ${Green_font_prefix}81.${Font_color_suffix} 查询配置信息        --忘记API时一键查询
 ${Green_font_prefix}82.${Font_color_suffix} 删除APIkey          --删除waha-api服务
 
  ——————————————N8N服务 自动化工作流软件 类似 make.com—————————————————
 ${Green_font_prefix}50.${Font_color_suffix} 安装N8N服务        --全新安装N8N工作流软件
 ${Green_font_prefix}51.${Font_color_suffix} 升级N8N服务        --升级最新N8N
 ${Green_font_prefix}52.${Font_color_suffix} 卸载N8N服务        --卸载并清空N8N服务

 ${Green_font_prefix}60.${Font_color_suffix} 安装NOCODE数据库        --全新安装NOCODE轻量数据库
 ${Green_font_prefix}61.${Font_color_suffix} 升级NOCODE数据库        --升级最新NOCODE
 ${Green_font_prefix}62.${Font_color_suffix} 卸载NOCODE数据库        --卸载并清空NOCODE服务

  ——————————————lobechat服务 如果提示未安装 不影响WhatsApp 自动对话服务机器人——————————
 ${Green_font_prefix}10.${Font_color_suffix} 安装lobechat服务    --全新安装lobechat
 ${Green_font_prefix}11.${Font_color_suffix} 升级lobechat服务    --升级最新lobechat
 ${Green_font_prefix}12.${Font_color_suffix} 卸载lobechat服务    --卸载并清空lobechat所有安装
 
  ———————————————开心版宝塔面板———————————————————————————————————
 ${Green_font_prefix}20.${Font_color_suffix} 安装开心版宝塔面板    --测试功能给有需要的人
 ${Green_font_prefix}21.${Font_color_suffix} 卸载开心版宝塔面板    
  ——————————————1Panel面板———————————————————————————————————————
 ${Green_font_prefix}30.${Font_color_suffix} 安装1Panel面板        --测试功能给有需要的人，集成了AI大模型UI一键安装
 ${Green_font_prefix}31.${Font_color_suffix} 卸载1Panel面板        
  —————————————测试服务器的IP质量—————————————————————————————————
 ${Green_font_prefix}40.${Font_color_suffix} 测试服务器的IP质量是否支持ChatGPT    --测试功能
  —————————————一键安装梯子——————————————————————————————————
 ${Green_font_prefix}66.${Font_color_suffix} 隐藏功能，利用闲置资源上网           --测试功能，请忽略广告，若有意外概不负责
 ${Green_font_prefix}67.${Font_color_suffix} 删除上述功能
  ——————————————查看CPU占用—————————————————————————————————————————
 ${Green_font_prefix}99.${Font_color_suffix} 查看VPS前十CPU进程    --如果遇到whatsapp频繁死机，重启故障依旧，排查VPS是否被植入木马或者挖矿程序
 ${Green_font_prefix}0.${Font_color_suffix} 退出脚本 
 
 ${Green_font_prefix}首次运行 请按照 2 3 依次运行；重新安装请选择 1 升级代码； 然后选择 4 卸载； 再选择 3 全新安装 ${Font_color_suffix} 
 ${Green_font_prefix}密码为 颜sir购买的 dckr_pat_开头的那段密码${Font_color_suffix} 
 ${Green_font_prefix}如果输入错误或者乱码请按CTRL + C 退出脚本 并重新运行${Font_color_suffix} 
————————————————————————————————————————————————————————————————" &&
  get_system_info
  echo -e " 系统信息: ${Font_color_suffix}$opsy ${Green_font_prefix}$virtual${Font_color_suffix} $arch ${Green_font_prefix}$kern${Font_color_suffix} "
# 获取所有架构

all_architectures=(
  "x86_64"
  "armv7l"
  "arm64"
  "ppc64le"
  "s390x"
  "aarch64"
  "riscv64"
)

# 遍历所有架构

for architecture in "${all_architectures[@]}"; do
  # 判断系统架构是否匹配

  if [[ $(get_system_architecture) == $architecture ]]; then
    echo -e " 当前系统架构：${Green_font_prefix}$architecture${Font_color_suffix} 获取当前IP地址 ${Green_font_prefix}$current_ip${Font_color_suffix}"
    break
  fi
done

# 如果没有匹配的架构，则输出提示

if [[ -z $architecture ]]; then
  echo " 无法识别系统架构"
fi

  read -p " 请输入数字 :" num
  case "$num" in
  1)
    Update_Shell
    ;;
  2)
    install_docker
    ;;
  3)
    install_whatsapp
    ;;
  4)
    uninstall_whatsapp
    ;;
  5)
    update_whatsapp
    ;;
  6)
    findpw
    ;;
  7)
    restartwhatsapp
    ;;
  8)
    whatsappapi
    ;;
  10)
    install_lobechat
    ;;
  11)
    update_lobechat
    ;;
  12)
    uninstall_lobechat
    ;;
  20)
    install_bt
    ;;
  21)
    uninstall_bt
    ;;
  30)
    install_onepanel
    ;;
  31)
    uninstall_onepanel
    ;;
  40)
    testgpt
    ;;
  66)
    installvless
    ;;
  67)
    removevless
    ;;
  99)
    checkcpu
    ;;
  50)
    installn8n
    ;;
  51)
    updaten8n
    ;;
  52)
    deln8n
    ;;
  60)
    installnocodb
    ;;
  61)
    updatenocodb
    ;;
  62)
    uninstallnocodb
    ;;
  81)
    findwahaapi
    ;;
  82)
    delwahaapi
    ;;
  0)
    exit 1
    ;;
  *)
    clear
    echo -e "${Error}:请输入正确数字 [0-99]"
    sleep 2s
    start_menu
    ;;
  esac
}

#############系统检测组件#############

#检查系统
check_sys() {
  if [[ -f /etc/redhat-release ]]; then
    release="centos"
  elif grep -qi "debian" /etc/issue; then
    release="debian"
  elif grep -qi "ubuntu" /etc/issue; then
    release="ubuntu"
  elif grep -qi -E "centos|red hat|redhat" /etc/issue || grep -qi -E "centos|red hat|redhat" /proc/version; then
    release="centos"
  fi

  if [[ -f /etc/debian_version ]]; then
    OS_type="Debian"
    echo "检测为Debian通用系统，判断有误请反馈"
  elif [[ -f /etc/redhat-release || -f /etc/centos-release || -f /etc/fedora-release ]]; then
    OS_type="CentOS"
    echo "检测为CentOS通用系统，判断有误请反馈"
  else
    echo "Unknown"
  fi

  #from https://github.com/oooldking

  _exists() {
    local cmd="$1"
    if eval type type >/dev/null 2>&1; then
      eval type "$cmd" >/dev/null 2>&1
    elif command >/dev/null 2>&1; then
      command -v "$cmd" >/dev/null 2>&1
    else
      which "$cmd" >/dev/null 2>&1
    fi
    local rt=$?
    return ${rt}
  }

  get_opsy() {
    if [ -f /etc/os-release ]; then
      awk -F'[= "]' '/PRETTY_NAME/{print $3,$4,$5}' /etc/os-release
    elif [ -f /etc/lsb-release ]; then
      awk -F'[="]+' '/DESCRIPTION/{print $2}' /etc/lsb-release
    elif [ -f /etc/system-release ]; then
      cat /etc/system-release | awk '{print $1,$2}'
    fi
  }

  get_system_info() {
    opsy=$(get_opsy)
    arch=$(uname -m)
    kern=$(uname -r)
    virt_check
  }
  # from LemonBench
  virt_check() {
    if [ -f "/usr/bin/systemd-detect-virt" ]; then
      Var_VirtType="$(/usr/bin/systemd-detect-virt)"
      # 虚拟机检测
      if [ "${Var_VirtType}" = "qemu" ]; then
        virtual="QEMU"
      elif [ "${Var_VirtType}" = "kvm" ]; then
        virtual="KVM"
      elif [ "${Var_VirtType}" = "zvm" ]; then
        virtual="S390 Z/VM"
      elif [ "${Var_VirtType}" = "vmware" ]; then
        virtual="VMware"
      elif [ "${Var_VirtType}" = "microsoft" ]; then
        virtual="Microsoft Hyper-V"
      elif [ "${Var_VirtType}" = "xen" ]; then
        virtual="Xen Hypervisor"
      elif [ "${Var_VirtType}" = "bochs" ]; then
        virtual="BOCHS"
      elif [ "${Var_VirtType}" = "uml" ]; then
        virtual="User-mode Linux"
      elif [ "${Var_VirtType}" = "parallels" ]; then
        virtual="Parallels"
      elif [ "${Var_VirtType}" = "bhyve" ]; then
        virtual="FreeBSD Hypervisor"
      # 容器虚拟化检测
      elif [ "${Var_VirtType}" = "openvz" ]; then
        virtual="OpenVZ"
      elif [ "${Var_VirtType}" = "lxc" ]; then
        virtual="LXC"
      elif [ "${Var_VirtType}" = "lxc-libvirt" ]; then
        virtual="LXC (libvirt)"
      elif [ "${Var_VirtType}" = "systemd-nspawn" ]; then
        virtual="Systemd nspawn"
      elif [ "${Var_VirtType}" = "docker" ]; then
        virtual="Docker"
      elif [ "${Var_VirtType}" = "rkt" ]; then
        virtual="RKT"
      # 特殊处理
      elif [ -c "/dev/lxss" ]; then # 处理WSL虚拟化
        Var_VirtType="wsl"
        virtual="Windows Subsystem for Linux (WSL)"
      # 未匹配到任何结果, 或者非虚拟机
      elif [ "${Var_VirtType}" = "none" ]; then
        Var_VirtType="dedicated"
        virtual="None"
        local Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
          Var_VirtType="Unknown"
          virtual="Unknown with SeaBIOS BIOS"
        else
          Var_VirtType="dedicated"
          virtual="Dedicated with ${Var_BIOSVendor} BIOS"
        fi
      fi
    elif [ ! -f "/usr/sbin/virt-what" ]; then
      Var_VirtType="Unknown"
      virtual="[Error: virt-what not found !]"
    elif [ -f "/.dockerenv" ]; then # 处理Docker虚拟化
      Var_VirtType="docker"
      virtual="Docker"
    elif [ -c "/dev/lxss" ]; then # 处理WSL虚拟化
      Var_VirtType="wsl"
      virtual="Windows Subsystem for Linux (WSL)"
    else # 正常判断流程
      Var_VirtType="$(virt-what | xargs)"
      local Var_VirtTypeCount
      Var_VirtTypeCount="$(echo $Var_VirtTypeCount | wc -l)"
      if [ "${Var_VirtTypeCount}" -gt "1" ]; then # 处理嵌套虚拟化
        virtual="echo ${Var_VirtType}"
        Var_VirtType="$(echo ${Var_VirtType} | head -n1)"                          # 使用检测到的第一种虚拟化继续做判断
      elif [ "${Var_VirtTypeCount}" -eq "1" ] && [ "${Var_VirtType}" != "" ]; then # 只有一种虚拟化
        virtual="${Var_VirtType}"
      else
        local Var_BIOSVendor
        Var_BIOSVendor="$(dmidecode -s bios-vendor)"
        if [ "${Var_BIOSVendor}" = "SeaBIOS" ]; then
          Var_VirtType="Unknown"
          virtual="Unknown with SeaBIOS BIOS"
        else
          Var_VirtType="dedicated"
          virtual="Dedicated with ${Var_BIOSVendor} BIOS"
        fi
      fi
    fi
  }

  #检查依赖
  if [[ "${OS_type}" == "CentOS" ]]; then
    # 检查是否安装了 ca-certificates 包，如果未安装则安装
    if ! rpm -q ca-certificates >/dev/null; then
      echo '正在安装 ca-certificates 包...'
      yum install ca-certificates -y
      update-ca-trust force-enable
    fi
    echo 'CA证书检查OK'

    # 检查并安装 curl、wget 和 dmidecode 包
    for pkg in curl wget git sudo; do
      if ! type $pkg >/dev/null 2>&1; then
        echo "未安装 $pkg，正在安装..."
        yum install $pkg -y
      else
        echo "$pkg 已安装。"
      fi
    done

    if [ -x "$(command -v lsb_release)" ]; then
      echo "lsb_release 已安装"
    else
      echo "lsb_release 未安装，现在开始安装..."
      yum install epel-release -y
      yum install redhat-lsb-core -y
    fi

  elif [[ "${OS_type}" == "Debian" ]]; then
    # 检查是否安装了 ca-certificates 包，如果未安装则安装
    if ! dpkg-query -W ca-certificates >/dev/null; then
      echo '正在安装 ca-certificates 包...'
      apt-get update || apt-get --allow-releaseinfo-change update && apt-get install ca-certificates -y
      update-ca-certificates
    fi
    echo 'CA证书检查OK'

    # 检查并安装 curl、wget 和 dmidecode 包
    for pkg in curl wget git yq sudo; do
      if ! type $pkg >/dev/null 2>&1; then
        echo "未安装 $pkg，正在安装..."
        apt-get update || apt-get --allow-releaseinfo-change update && apt-get install $pkg -y
      else
        echo "$pkg 已安装。"
      fi
    done

    if [ -x "$(command -v lsb_release)" ]; then
      echo "lsb_release 已安装"
    else
      echo "lsb_release 未安装，现在开始安装..."
      apt-get install lsb-release -y
    fi

  else
    echo "不支持的操作系统发行版：${release}"
    exit 1
  fi
}

#检查Linux版本
check_version() {
  if [[ -s /etc/redhat-release ]]; then
    version=$(grep -oE "[0-9.]+" /etc/redhat-release | cut -d . -f 1)
  else
    version=$(grep -oE "[0-9.]+" /etc/issue | cut -d . -f 1)
  fi
  bit=$(uname -m)
  check_github
}

install_yansir(){
    
read -p "请输入 whatsapp-http-api-plus 密码：" apipw


echo "$apipw" | docker login -u devlikeapro --password-stdin

# 获取系统架构
architecture=$(uname -m)

# 判断系统架构并输出不同文字
if [[ $architecture == "x86_64" ]]; then
 apiarch="docker-compose.yml"
elif [[ $architecture == "armv7l" ]]; then
 apiarch="arm-compose.yml"
elif [[ $architecture == "aarch64" ]]; then
 apiarch="arm-compose.yml"
else
 apiarch="docker-compose.yml"
fi


 git clone https://github.com/jerryrat/whatsapp-docker-compose-file.git && cd whatsapp-docker-compose-file && docker login -u devlikeapro -p $apipw && docker-compose -f ${apiarch} up -d  && docker logout


}

# 检查安装要求
install_whatsapp() {
    rm -rf whatsapp-docker-compose-file

    check_disk_space

    # 检查 Docker 是否安装
    if ! command -v docker >/dev/null 2>&1; then
        echo -e "${Error}Docker 未安装，请按键盘任意键返回菜单后选择 2 安装 Docker"
        echo
        break_end
        start_menu
    fi

    # 检查 yansir-network 网络是否存在
    if docker network ls | grep -q yansir-network; then
        echo -e " 看起来你曾经安装过WhatsApp机器人且${Green_font_prefix}yansir-network${Font_color_suffix} 网络已存在，不建议覆盖安装"
        echo -e "请按键盘任意按键返回主菜单选择 或者访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix}进行机器人的更多设置"
        echo
    else
        # 检查是否存在类似网络
        networks=$(docker network ls --format '{{.Name}}' | grep -v "NETWORK ID")
        for network in $networks; do
            if [[ $network =~ "yansir-network" ]]; then
                echo -e " 看起来你曾经安装过WhatsApp机器人且${Green_font_prefix}yansir-network${Font_color_suffix} 网络已存在，不建议覆盖安装"
                echo -e "请按键盘任意按键返回主菜单选择 或者访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix}进行机器人的更多设置"
                echo
                # 删除网络
                docker network rm "$network"
            fi
        done
    fi

    # 定义容器列表
    containers=(
        "mongo"
        "mongo-express"
        "redis"
        "yansir-whatsapp"
        "waha"
        "whatsapp-api"
    )

    # 检查容器是否存在并正常运行
    for container in "${containers[@]}"; do
        # 检查容器是否存在(包括运行中和停止的)
        if docker ps -a --format '{{.Names}}' | grep -q "^${container}\$"; then
            # 检查容器是否正在运行
            if docker ps --format '{{.Names}}' --filter status=running | grep -q "^${container}\$"; then
                echo -e " ${Green_font_prefix}$container${Font_color_suffix}服务且正常运行，不建议覆盖安装，请按键盘任意按键返回主菜单选择"
            else
                echo -e " ${Error} 看起来你曾经安装过 ${Green_font_prefix}$container${Font_color_suffix}服务但停止中"
                echo -e "请按键盘任意按键返回主菜单选择 请选择4删除后重新安装并启动"
                echo
            fi
    done

    # 如果所有服务正常运行，提示访问地址
    if docker ps | grep -q "waha"; then
        echo -e " 如果所有服务正常运行，请访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix}进行机器人的更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
    fi

break_end
start_menu
    
}


#删除WhatsApp
uninstall_whatsapp() {

#!/bin/bash


read -p "确定删除全部数据库和镜像，恢复初始状态? 一旦删除所有聊天记录将彻底删除 确定请按Y: " confirm

#if [[ $confirm == "Y" ]]; then
case $confirm in
     [yY])

rm -rf whatsapp-docker-compose-file

# 定义要检查的容器和镜像名称

containers=(
  "mongo"
  "mongo-express"
  "redis"
  "yansir-whatsapp"
  "qdrant"
  "waha"
  "whatsapp-http-api"
)

images=(
  "mongo"
  "mongo-express"
  "redis"
  "yansir-whatsapp"
  "qdrant"
  "waha-plus"
  "whatsapp-http-api"
)

# 检查容器

for container in "${containers[@]}"; do
  if docker ps -a | grep -q "$container"; then
    echo "发现容器：$container"
  fi
done

# 删除容器

for container in "${containers[@]}"; do
  if docker ps -a | grep -q "$container"; then
    docker rm -f $(docker ps -a | grep -E "$container" | awk '{print $1}')
    echo "已删除容器：$container"
  fi
done

# 检查镜像

for image in "${images[@]}"; do
  if docker images | grep -q "$image"; then
    echo "发现镜像：$image"
  fi
done

# 删除镜像

for image in "${images[@]}"; do
  if docker images | grep -q "$image"; then
    docker rmi -f $(docker images | grep -E "$image" | awk '{print $3}')
    echo "已删除镜像：$image"
  fi
done


# 检查网络是否存在
networks=$(docker network ls | grep -v "NETWORK ID")

for network in $networks; do
  if [[ $network =~ "yansir-network" ]]; then
    echo -e "存在网络 ${Green_font_prefix}yansir-network${Font_color_suffix} "
    
    # 删除网络
    docker network rm $network   
    echo -e "已删除网络${Green_font_prefix}yansir-network${Font_color_suffix}"
  fi
done
;;
*)
  echo "已取消删除"
;;
esac
echo
break_end
start_menu

}

check_containers() {
containers=(
  "mongo"
  "mongo-express"
  "redis"
  "yansir-whatsapp"
  "waha"
  "whatsapp-api"
)

# 检查容器是否存在并正常运行
for container in "${containers[@]}"; do
    # 检查容器是否存在(包括运行中和停止的)
  if docker ps -a --format '{{.Names}}' | grep -q "^${container}\$"; then
        # 检查容器是否正在运行
    if docker ps --format '{{.Names}}' --filter status=running | grep -q "^${container}\$"; then
      echo -e " 已安装${Green_font_prefix}$container${Font_color_suffix}服务正常运行"
    else
      echo -e " ${Error}  ${Green_font_prefix}$container${Font_color_suffix}服务已安装但停止中(启动失败) 请重启服务器后检测 或者重新安装并启动"
    fi
  else
      echo -e " ${Error} 未安装${Green_font_prefix}$container${Font_color_suffix} 服务 如需要请安装服务"
  fi
done

}

check_whatsapp() {
    



echo && echo 

if ! command -v docker >/dev/null 2>&1; then
      echo -e "${Error}Docker 未安装，按键盘任意键返回菜单后选择 2 安装 Docker"
      echo
      break_end
      start_menu
      exit 0
fi

    
if docker network ls | grep -q "yansir-network"; then


    check_containers
    echo -e " ${YELLOW} whatsapp-api 为DIY扩展二次开发功能不影响WhatsApp机器人${NC}"    
    echo -e " 已建立${Green_font_prefix}yansir-network${Font_color_suffix}网络 正常运行 请访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix} 进行机器人的更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
        
else
# 网络不存在
    check_containers
    echo -e " ${YELLOW} whatsapp-api 为DIY扩展二次开发功能不影响WhatsApp机器人${NC}"
    echo -e " ${Error} 未建立${Green_font_prefix}yansir-network${Font_color_suffix}网络 请依次安装服务"
fi

  
}


# 定义一个函数，用于获取系统架构

get_system_architecture() {
  # 获取操作系统名称

  system=$(uname -s)

  # 获取系统架构

  architecture=$(uname -m)

  # 判断操作系统类型

  if [[ $system == "Linux" ]]; then
    # 判断系统架构

    if [[ $architecture == "x86_64" ]]; then
      echo "x86_64"
    elif [[ $architecture == "armv7l" ]]; then
      echo "armv7l"
    else
      echo "$architecture"
    fi
  elif [[ $system == "Windows" ]]; then
    # 判断系统架构

    if [[ $architecture == "AMD64" ]]; then
      echo "x86_64"
    elif [[ $architecture == "x86" ]]; then
      echo "x86"
    else
      echo "$architecture"
    fi
  else
    echo "$architecture"
  fi
  

  
}


install_add_docker() {
    if [ -f "/etc/alpine-release" ]; then
        sudo apk update
        sudo apk add docker docker-compose
        sudo rc-update add docker default
        sudo service docker start
        echo
        break_end
        start_menu
    else
        sudo curl -fsSL https://get.docker.com | sh && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin
        sudo systemctl start docker
        sudo systemctl enable docker
        echo
        break_end
        start_menu
    fi
}

install_docker() {
    if ! command -v docker &>/dev/null; then
        install_add_docker || {
            echo -e "${Red_font_prefix}Docker 安装失败！${Font_color_suffix}"
            read -n 1 -s -r -p "按任意键返回主菜单..."
            start_menu
            return 1
        }
    else
        echo -e "${Green_font_prefix}Docker 已经安装。${Font_color_suffix}"
        read -n 1 -s -r -p "按任意键返回主菜单..."
        start_menu
    fi
}


#升级
update_whatsapp() {

# 查找名为 “whatsapp-http-api” 的容器 未升级前的旧版本
container_id=$(docker ps -a | grep whatsapp-http-api | awk '{print $1}')

# 如果容器存在，则停止并删除容器和卷
if [ -n "$container_id" ]; then
  echo "停止容器 $container_id ..."
  docker stop $container_id

  echo "删除容器 $container_id 和关联卷 ..."
  docker rm -f $container_id
else
  echo "未找到容器 whatsapp-http-api。"
fi
# 未升级前的旧版本删除结束

rm -rf whatsapp-docker-compose-file

read -p "请输入 whatsapp-http-api-plus 密码" apipw


echo "$apipw" | docker login -u devlikeapro --password-stdin

# 获取系统架构
architecture=$(uname -m)

# 判断系统架构并输出不同文字
if [[ $architecture == "x86_64" ]]; then
 apiarch="update.yml"
elif [[ $architecture == "armv7l" ]]; then
 apiarch="arm-update.yml"
elif [[ $architecture == "aarch64" ]]; then
 apiarch="arm-update.yml"
else
 apiarch="update.yml"
fi


git clone https://github.com/jerryrat/whatsapp-docker-compose-file.git && cd whatsapp-docker-compose-file ; docker login -u devlikeapro -p $apipw && docker-compose -f ${apiarch}  pull  && docker-compose -f ${apiarch} up -d  && docker logout

echo -e " ${Green_font_prefix}升级完成${Font_color_suffix} 如果所有服务正常（running or started）运行，请访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix} 进行机器人的更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
echo
break_end
start_menu
}


#删除lobechat
install_lobechat() {

#!/bin/bash

check_disk_space
    
    
    if ! command -v docker >/dev/null 2>&1; then
      echo "Docker 未安装，请按键盘任意键返回菜单后选择 2 安装 Docker"
      echo
      break_end
      start_menu
    fi

    
docker pull lobehub/lobe-chat

read -p "请输入 Openai API key 如果没有请学习如何申请：" openaiapi

docker run -d -p 3210:3210 \
  -e OPENAI_API_KEY="$openaiapi" \
  -e ACCESS_CODE=lobe66 \
  --name lobe-chat \
  lobehub/lobe-chat

echo -e " ${Green_font_prefix}lobe-chat 安装完成${Font_color_suffix} 如果所有服务正常（running or started）运行，请访问 ${Green_font_prefix}http://$current_ip:3210${Font_color_suffix} 进行更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"

echo -e " ${Green_font_prefix}如果登录时或者聊天时要求输入密码，就输入lobe66${Font_color_suffix} "
echo
break_end
start_menu

}

#删除lobechat
uninstall_lobechat() {

#!/bin/bash


read -p "确定删除全部lobechat，恢复初始状态? 一旦删除所有聊天记录将彻底删除 确定请按Y: " confirm

#if [[ $confirm == "Y" ]]; then

case $confirm in
     [yY])


# 删除包含 "lobe-chat" 的容器
docker ps -a | grep "lobe-chat" | awk '{print $1}' | xargs -r docker rm -f

# 删除包含 "lobe-chat" 的镜像
docker images | grep "lobe-chat" | awk '{print $3}' | xargs -r docker rmi -f


echo -e "${Green_font_prefix}Lobe Chat 全部删除成功 按键盘任意按键将返回主菜单${Font_color_suffix}"
      
;;
*)
  echo "已取消删除"
;;
esac
echo
break_end
start_menu

}

#升级lobechat
update_lobechat() {

#!/bin/bash

# 检查是否包含 "lobe-chat" 的容器
if docker ps -a --format '{{.Names}}' | grep -q "lobe-chat"; then
    echo "包含 'lobe-chat' 的容器存在."

#!/bin/bash
# auto-update-lobe-chat.sh

# 设置代理（可选）
export https_proxy=http://127.0.0.1:7890 http_proxy=http://127.0.0.1:7890 all_proxy=socks5://127.0.0.1:7890

# 拉取最新的镜像并将输出存储在变量中
output=$(docker pull lobehub/lobe-chat:latest 2>&1)

# 检查拉取命令是否成功执行
if [ $? -ne 0 ]; then
  exit 1
fi

# 检查输出中是否包含特定的字符串
echo "$output" | grep -q "Image is up to date for lobehub/lobe-chat:latest"

# 如果镜像已经是最新的，则不执行任何操作
if [ $? -eq 0 ]; then
  exit 0
fi

echo "Detected Lobe-Chat update"

# 删除旧的容器
echo "Removed: $(docker rm -f Lobe-Chat)"

# 运行新的容器
echo "Started: $(docker run -d --network=host --env-file /path/to/lobe.env --name=Lobe-Chat --restart=always lobehub/lobe-chat)"

# 打印更新的时间和版本
echo "Update time: $(date)"
echo "Version: $(docker inspect lobehub/lobe-chat:latest | grep 'org.opencontainers.image.version' | awk -F'"' '{print $4}')"

# 清理不再使用的镜像
docker images | grep 'lobehub/lobe-chat' | grep -v 'latest' | awk '{print $3}' | xargs -r docker rmi > /dev/null 2>&1
echo "Removed old images."

echo -e "${Green_font_prefix}Lobe Chat 升级成功 按键盘任意按键将返回主菜单${Font_color_suffix}"

else
    echo -e " ${Error} 没有找到包含 ${Green_font_prefix}lobe-chat${Font_color_suffix}服务 请选择10安装服务"
fi
echo
break_end
start_menu

}
#安装宝塔
install_bt() {
wget -O install.sh http://io.bt.sy/install/install-ubuntu_6.0.sh && sudo bash install.sh
}

#卸载宝塔
uninstall_bt() {
wget -O bt-uninstall.sh http://download.bt.cn/install/bt-uninstall.sh && sudo bash bt-uninstall.sh
echo
break_end
start_menu
}

#安装1panel
install_onepanel() {
wget -O quick_start.sh https://resource.fit2cloud.com/1panel/package/quick_start.sh && sudo bash quick_start.sh
}
#卸载1panel
uninstall_onepanel() {
1pctl uninstall
echo
break_end
start_menu
}
#测试IP
testgpt() {
bash <(curl -Ls IP.Check.Place)
echo
break_end
start_menu
}


#建梯子
installvless(){
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
echo -e " ${Red_font_prefix}请忽略上面的任何广告信息${Font_color_suffix}，${Green_font_prefix}复制上面生成的信息或者链接到你的梯子app${Font_color_suffix}"
echo
break_end
start_menu
}

#删梯子
removevless(){
sing-box un
echo
break_end
start_menu
}

#查找密码
findpw() {
echo
echo -e "请访问 ${Green_font_prefix}http://$current_ip:8081/db/admin/authCollection${Font_color_suffix}"
echo -e "登录用户名 ${Green_font_prefix}yansir${Font_color_suffix}"
echo -e "登录密码 ${Green_font_prefix}Ydj2qEhshAHwMnm2${Font_color_suffix}"
echo -e "登录后会显示明文密码，请勿泄露"
echo
break_end
start_menu
}

#重启服务
restartwhatsapp() {
for container in $(docker ps -aq); do
  name=$(docker inspect --format='{{.Name}}' $container | cut -c2-)
  if docker restart $container; then
    echo -e "${Green_font_prefix}服务（$(docker inspect --format='{{.Name}}' $container | cut -c2-)）重启成功${Font_color_suffix}"
  else
    echo -e "${Red_font_prefix}服务（$(docker inspect --format='{{.Name}}' $container | cut -c2-)）重启失败，请尝试选择 4 卸载软件并选择 3 重装${Font_color_suffix}"
  fi
done
echo
break_end
start_menu
}

#重启服务
checkcpu() {
echo
echo -e "${Green_font_prefix}通过此菜单可以查看CPU和内存占用率，如果过高，请联系客服排查${Font_color_suffix}"
ps aux --sort=-%cpu | awk 'NR==1{printf "%-8s %-8s %-8s %-8s %-8s\n", "用户", "PID", "CPU使用率%", "内存使用率%", "进程名称"; next} NR<=11{printf "%-8s %-12s %-12s %-12s %-20s\n", $1, $2, $3, $4, $11}'
echo
break_end
start_menu
}


# 检查 yq 是否安装
check_yq_installed() {
    if ! command -v yq &> /dev/null; then
        echo -e "${Red_font_prefix}未找到 yq 工具，请先安装 yq！${Font_color_suffix}"
        echo "尝试自动安装..."
        pip install yq
        exit 1
    fi
}


#添加API
whatsappapi() {

echo -e "${Green_font_prefix}通过此菜单可以添加API服务，安装后请务必截图或者复制保存${Font_color_suffix}"

# 查找名为 “whatsapp-api” 的容器
container_id=$(docker ps -a | grep whatsapp-api | awk '{print $1}')

# 如果容器存在，则停止并删除容器和卷
if [ -n "$container_id" ]; then
  echo "停止容器 $container_id ..."
  docker stop $container_id

  echo "删除容器 $container_id 和关联卷 ..."
  docker rm -f $container_id
else
  echo "未找到容器 whatsapp-api。"
fi


rm -rf whatsapp-docker-compose-file

read -p "请输入 whatsapp-http-api-plus 密码" apipw


echo "$apipw" | docker login -u devlikeapro --password-stdin


git clone https://github.com/jerryrat/whatsapp-docker-compose-file.git && cd whatsapp-docker-compose-file

echo -e "${Green_font_prefix}请输入 WAHA API 管理的用户名和密码：${Font_color_suffix}"
read -p "API管理平台的用户名: " apiusername
read -p "API管理平台的密码: " apipassword

# 检查输入是否为空
if [[ -z "$apiusername" || -z "$apipassword" ]]; then
  echo -e "${Red_font_prefix}用户名和密码不能为空！${Font_color_suffix}"
  exit 1
fi

# 设置随机字符串长度
LENGTH=32
# 生成随机字符串
RANDOM_STRING=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c $LENGTH)
# 添加 "wa-" 前缀
API_KEY="wa-$RANDOM_STRING"
# 输出 API Key
echo
echo
echo
echo -e "${Green_font_prefix}请截图保存或者复制保存${Font_color_suffix}"
echo -e "WAHA API 管理的用户名和密码为:${Green_font_prefix} $apiusername ${Font_color_suffix} API管理平台的密码为:${Green_font_prefix} $apipassword ${Font_color_suffix} "
echo -e "WAHA API Metadata X-Api-Key 为:${Green_font_prefix} $API_KEY ${Font_color_suffix}"
echo -e "WAHA API 管理平台为:${Green_font_prefix} http://$current_ip:3003/dashboard/ ${Font_color_suffix}"
echo
echo
# 使用 sed 更新 YAML 文件 暂时不能用
# sed -i "/waha:/a \    environment:\n      WAHA_DASHBOARD_USERNAME: $apiusername\n      WAHA_DASHBOARD_PASSWORD: $apipassword\n      WHATSAPP_API_KEY: $API_KEY" ${apiarch}

# 使用 sed 更新 YAML 文件
sed -i "/waha:/a \    environment:\n      WAHA_DASHBOARD_USERNAME: $apiusername\n      WAHA_DASHBOARD_PASSWORD: $apipassword\n      WHATSAPP_API_KEY: $API_KEY" ${apiarch}

echo -e "${Green_font_prefix}API服务正在安装更新！${Font_color_suffix}"
echo -e "${Green_font_prefix}开始安装！${Font_color_suffix}"

# 查找包含 yansir-network 的 Docker 网络名称
apinetwork=$(docker network ls --filter "name=yansir-network" --format "{{.Name}}" | head -n 1)

# 如果没有找到相关网络，则创建一个新的网桥
if [[ -z "$apinetwork" ]]; then
    echo "未找到 yansir-network 网络，正在创建 yansir-network-api..."
    docker network create yansir-network-api
    apinetwork="yansir-network-api"
fi

# 输出结果
echo "使用的网络名称: $apinetwork"

# 获取系统架构
architecture=$(uname -m)

# 判断系统架构并输出不同文字
if [[ $architecture == "x86_64" ]]; then
 docker run -d --name whatsapp-api -e WAHA_DASHBOARD_USERNAME=$apiusername -e WAHA_DASHBOARD_PASSWORD=$apipassword -e WHATSAPP_API_KEY=$API_KEY -p 3003:3000 --network $apinetwork devlikeapro/waha-plus
elif [[ $architecture == "armv7l" ]]; then
 docker run -d --name whatsapp-api -e WAHA_DASHBOARD_USERNAME=$apiusername -e WAHA_DASHBOARD_PASSWORD=$apipassword -e WHATSAPP_API_KEY=$API_KEY -p 3003:3000 --network $apinetwork devlikeapro/waha-plus:arm
elif [[ $architecture == "aarch64" ]]; then
 docker run -d --name whatsapp-api -e WAHA_DASHBOARD_USERNAME=$apiusername -e WAHA_DASHBOARD_PASSWORD=$apipassword -e WHATSAPP_API_KEY=$API_KEY -p 3003:3000 --network $apinetwork devlikeapro/waha-plus:arm
else
 docker run -d --name whatsapp-api -e WAHA_DASHBOARD_USERNAME=$apiusername -e WAHA_DASHBOARD_PASSWORD=$apipassword -e WHATSAPP_API_KEY=$API_KEY -p 3003:3000 --network $apinetwork devlikeapro/waha-plus
fi

docker logout

echo -e " ${Green_font_prefix}API升级完成${Font_color_suffix} 如果所有服务正常（running or started）运行，请访问 ${Green_font_prefix}http://$current_ip:3003/dashboard/${Font_color_suffix} 进行API的更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
echo -e " ${Green_font_prefix}请更新面板中的 Metadata X-Api-Key 登录用户名密码参见截图 ${Font_color_suffix} "

echo
break_end
start_menu
}


#安装n8n
installn8n() {

#!/bin/bash

# 容器名称
CONTAINER_NAME="n8n"

# 检查容器是否存在
if docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo -e " ${Green_font_prefix}n8n已经安装${Font_color_suffix} 请访问 ${Green_font_prefix}http://$current_ip:5678/${Font_color_suffix} 进行更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
  echo -e " ${Green_font_prefix}如果有问题请直接升级，会保留上次安装的配置和自动化脚本${Font_color_suffix}"
  break_end
  start_menu
fi

# 提示用户输入域名地址
read -p "请输入域名地址（回车默认使用当前 IP 地址 $current_ip）：" domain

# 如果用户直接回车，则使用当前 IP 地址
if [ -z "$domain" ]; then
  domain=$current_ip
fi

# 输出结果
echo "使用的地址为：$domain"
docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e N8N_SECURE_COOKIE=false  -e N8N_HOST=$domain -e WEBHOOK_URL=https://$domain -e GENERIC_TIMEZONE=Asia/Shanghai docker.n8n.io/n8nio/n8n
echo -e " ${Green_font_prefix}n8n安装成功${Font_color_suffix} 请访问 ${Green_font_prefix}http://$domain:5678/${Font_color_suffix} 进行更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"

echo
break_end
start_menu

}

#升级n8n
updaten8n() {

#!/bin/bash

# 容器名称
CONTAINER_NAME="n8n"

# 检查容器是否存在
if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "n8n 程序不存在，无需升级。"
  break_end
  start_menu
fi

# 容器名称
CONTAINER_NAME="n8n"

# 停止并删除旧容器
echo "停止并升级旧程序..."
docker stop $CONTAINER_NAME
docker rm $CONTAINER_NAME

echo -e " ${Green_font_prefix}升级过程会保留上次安装的配置和自动化脚本${Font_color_suffix}"
# 拉取最新镜像
echo "拉取最新镜像..."
docker pull docker.n8n.io/n8nio/n8n

# 重新运行容器
echo "重新运行容器..."

# 提示用户输入域名地址
read -p "请输入域名地址（回车默认使用当前 IP 地址 $current_ip）：" domain

# 如果用户直接回车，则使用当前 IP 地址
if [ -z "$domain" ]; then
  domain=$current_ip
fi

# 输出结果
echo "使用的地址为：$domain"
docker run -d --name n8n -p 5678:5678 -v n8n_data:/home/node/.n8n -e N8N_SECURE_COOKIE=false  -e N8N_HOST=$domain -e WEBHOOK_URL=https://$domain -e GENERIC_TIMEZONE=Asia/Shanghai docker.n8n.io/n8nio/n8n
echo -e " ${Green_font_prefix}n8n升级成功${Font_color_suffix} 请访问 ${Green_font_prefix}http://$domain:5678/${Font_color_suffix} 进行更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"

echo
break_end
start_menu

}


#删除n8n
deln8n() {

#!/bin/bash

# 容器名称
CONTAINER_NAME="n8n"

# 镜像名称
IMAGE_NAME="docker.n8n.io/n8nio/n8n"

# Docker 卷名称
VOLUME_NAME="n8n_data"

# 检查容器是否存在
if ! docker ps -a --format '{{.Names}}' | grep -q "^$CONTAINER_NAME$"; then
  echo "n8n 容器不存在，无需删除。"
  exit 0
fi

# 提示用户确认删除
read -p "确定要删除 n8n 吗？这将彻底删除容器、镜像和数据卷！(y/n): " confirm

if [[ $confirm != "y" && $confirm != "Y" ]]; then
  echo "操作已取消。"
  exit 0
fi

# 停止并删除容器
echo "停止并删除容器..."
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# 删除镜像
echo "删除镜像..."
docker rmi $IMAGE_NAME 2>/dev/null

# 删除 Docker 卷
echo "删除 Docker 卷..."
docker volume rm $VOLUME_NAME 2>/dev/null

# 检查是否删除成功
echo "检查容器、镜像和卷是否已删除..."
docker ps -a | grep $CONTAINER_NAME
docker images | grep $(echo $IMAGE_NAME | cut -d'/' -f2-)
docker volume ls | grep $VOLUME_NAME

echo "n8n 已完全删除！"


echo
break_end
start_menu

}

#查询n8n
findwahaapi() {


docker exec whatsapp-api env | grep -E "WAHA_DASHBOARD_USERNAME|WAHA_DASHBOARD_PASSWORD|WHATSAPP_API_KEY"

echo
break_end
start_menu

}


# 检查Docker是否安装
check_docker_installed() {
    if ! command -v docker &> /dev/null; then
        echo -e "${RED}错误: Docker 未安装，请先安装Docker${NC}"
        exit 1
    fi
}

# 检查容器是否存在
check_container_exists() {
    if ! docker ps -a --format '{{.Names}}' | grep -q "^whatsapp-api$"; then
        echo -e "${YELLOW}提示: waha-api 容器不存在${NC}"
        exit 0
    fi
}

# 主函数
delwahaapimain() {
    echo -e "${BLUE}=== waha-api 容器删除脚本 ===${NC}"
    
    # 检查Docker
    check_docker_installed
    echo -e "${GREEN}✓ Docker 已安装${NC}"
    
    # 检查容器
    check_container_exists
    echo -e "${GREEN}✓ 找到 waha-api 容器${NC}"
    
    # 确认提示
    echo -e "${YELLOW}警告: 这将永久删除 waha-api 容器${NC}"
    read -p "确定要删除吗? [y/N]: " confirm
    
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo -e "${BLUE}操作已取消${NC}"
        exit 0
    fi
    
    # 执行删除
    echo -e "${YELLOW}正在删除 waha-api 容器...${NC}"
    docker rm -f whatsapp-api
    
    # 验证结果
    sleep 1
    if docker ps -a --format '{{.Names}}' | grep -q "^whatsapp-api$"; then
        echo -e "${RED}错误: 删除失败，waha-api 容器仍然存在${NC}"
        exit 1
    else
        echo -e "${GREEN}✓ waha-api 容器已成功删除${NC}"
        exit 1
    fi
}



#查询n8n
delwahaapi() {

delwahaapimain

echo
break_end
start_menu

}

# 变量配置
CONTAINER_NAME="nocodb"
VOLUME_NAME="nocodb_data"
PORT="8080"
IMAGE="nocodb/nocodb:latest"



# 安装NocoDB
installnocodb() {
    check_docker_installed
    
    if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        echo -e "${YELLOW}检测到已存在的NocoDB容器，请先卸载或更新${NC}"
        exit 1
    fi

    echo -e "${GREEN}正在安装NocoDB...${NC}"
    docker run -d --name ${CONTAINER_NAME} \
        -p ${PORT}:8080 \
        -v ${VOLUME_NAME}:/usr/app/data/ \
        ${IMAGE}

    echo -e "${GREEN}NocoDB 安装成功！${NC}"
    echo -e "访问地址: ${YELLOW}http://$domain:${PORT}${NC}"
    echo
    break_end
    start_menu
}

# 更新NocoDB
updatenocodb() {
    check_docker_installed

    if [ ! "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        echo -e "${YELLOW}未找到NocoDB容器，请先安装${NC}"
        exit 1
    fi

    echo -e "${GREEN}正在更新NocoDB...${NC}"
    
    echo "拉取最新镜像..."
    docker pull ${IMAGE}

    echo "停止并移除旧容器..."
    docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME}

    echo "启动新容器..."
    docker run -d --name ${CONTAINER_NAME} \
        -p ${PORT}:8080 \
        -v ${VOLUME_NAME}:/usr/app/data/ \
        ${IMAGE}

    echo -e "${GREEN}NocoDB 更新成功！${NC}"
    echo
    break_end
    start_menu
}

# 完全卸载
uninstallnocodb() {
    check_docker_installed

    read -p "确定要完全卸载NocoDB吗？这将删除所有数据！(y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}已取消卸载操作${NC}"
        exit 0
    fi

    echo -e "${RED}正在完全卸载NocoDB...${NC}"
    
    if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        echo "停止并删除容器..."
        docker stop ${CONTAINER_NAME} && docker rm -v ${CONTAINER_NAME}
    fi

    if [ "$(docker volume ls -q -f name=${VOLUME_NAME})" ]; then
        echo "删除数据卷..."
        docker volume rm ${VOLUME_NAME}
    fi

    echo "清理镜像..."
    docker rmi ${IMAGE} 2>/dev/null || true

    echo -e "${GREEN}NocoDB 已完全卸载！${NC}"
    echo
    break_end
    start_menu
}


#############系统检测组件#############
check_sys
check_version
check_disk_space
[[ "${OS_type}" == "Debian" ]] && [[ "${OS_type}" == "CentOS" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
check_whatsapp
break_end
start_menu
