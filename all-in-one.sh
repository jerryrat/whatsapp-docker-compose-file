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

sh_ver="3.2"
github="raw.githubusercontent.com/yansircc/WhatsApp/master"

  # 获取当前IP地址，设置超时为3秒
current_ip=$(curl -s --max-time 3 https://api.ipify.org)
  
  
imgurl=""
headurl=""
github_network=1

Green_font_prefix="\033[32m"
Red_font_prefix="\033[31m"
Font_color_suffix="\033[0m"
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
  break_end
  start_menu
}


#开始菜单
start_menu() {
  #clear 修复闪屏
  echo && echo -e " 颜sir WhatsApp 一键安装管理脚本 ${Red_font_prefix}[v${sh_ver}] 
 ${Green_font_prefix}1.${Font_color_suffix} 几乎用不着不用选    --颜Sir更新了脚本后选1自动更新vps本地脚本
 ${Green_font_prefix}2.${Font_color_suffix} 安装docker          --全系系统请务必安装docker环境，可以选择查看是否已经安装
 ${Green_font_prefix}3.${Font_color_suffix} 安装WhatsApp服务    --全自动安装服务
 ${Green_font_prefix}4.${Font_color_suffix} 卸载Whatsapp服务    --清空服务器从0开始配置，出了问题选这个删除重装
 ${Green_font_prefix}5.${Font_color_suffix} 更新WhatsApp服务    --保留数据库，只更新聊天服务插件
 ${Green_font_prefix}6.${Font_color_suffix} 查看WhatsApp设置密码 --请勿泄露IP
 
 ————————————————————————————————————————————————————————————————
  lobechat服务 如果提示未安装 不影响WhatsApp 自动对话服务机器人
 ${Green_font_prefix}10.${Font_color_suffix} 安装lobechat服务    --全新安装lobechat
 ${Green_font_prefix}11.${Font_color_suffix} 升级lobechat服务    --升级最新lobechat
 ${Green_font_prefix}12.${Font_color_suffix} 卸载lobechat服务    --卸载并清空lobechat所有安装
 
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}20.${Font_color_suffix} 安装开心版宝塔面板    --测试功能给有需要的人
 ${Green_font_prefix}21.${Font_color_suffix} 卸载开心版宝塔面板    
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}30.${Font_color_suffix} 安装1Panel面板        --测试功能给有需要的人，集成了AI大模型UI一键安装
 ${Green_font_prefix}31.${Font_color_suffix} 卸载1Panel面板        
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}40.${Font_color_suffix} 测试服务器的IP质量是否支持ChatGPT    --测试功能
————————————————————————————————————————————————————————————————
 ${Green_font_prefix}66.${Font_color_suffix} 隐藏功能，利用闲置资源上网           --测试功能，请忽略广告，若有意外概不负责
 ${Green_font_prefix}67.${Font_color_suffix} 删除上述功能
————————————————————————————————————————————————————————————————
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
    for pkg in curl wget git sudo; do
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

#检查安装要求
install_whatsapp() {

rm -rf whatsapp-docker-compose-file    
    
check_disk_space
    
    
    if ! command -v docker >/dev/null 2>&1; then
      echo -e "${Error}Docker 未安装，请按键盘任意键返回菜单后选择 2 安装 Docker"
      break_end
      start_menu
    fi

    # 检查 yansir-network 网络是否存在
    # 网络存在 继续安装
    if docker network ls | grep -q yansir-network; then
      echo -e " 看起来你曾经安装过WhatsApp机器人且${Green_font_prefix}yansir-network${Font_color_suffix} 网络已存在，不建议覆盖安装"
      echo -e "请按键盘任意按键返回主菜单选择"
      break_end
      start_menu
  else 
  
    # 检查 root-yansir-network 网络是否存在 或者类似的
    # 类似网络存在 删除
    networks=$(docker network ls | grep -v "NETWORK ID")
    
    for network in $networks; do
    if [[ $network =~ "yansir-network" ]]; then
      echo -e " 看起来你曾经安装过WhatsApp机器人且${Green_font_prefix}yansir-network${Font_color_suffix} 网络已存在，不建议覆盖安装"
      echo -e "请按键盘任意按键返回主菜单选择"
      break_end
      start_menu
      # 删除网络
     fi
    done

    
containers=(
  "mongo"
  "mongo-express"
  "redis"
  "yansir-whatsapp"
  "whatsapp-http-api"
  "waha"
  "lobe-chat"
)

# 检查容器是否存在并正常运行
for container in "${containers[@]}"; do
  if docker ps -a | grep -q "$container"; then
    if docker ps | grep -q "$container"; then
      echo -e " 看起来你曾经安装过${Green_font_prefix}$container${Font_color_suffix}服务且正常运行，不建议覆盖安装，请按键盘任意按键返回主菜单选择"
      break_end
      start_menu
    else
      echo -e " ${Error} 看起来你曾经安装过 ${Green_font_prefix}$container${Font_color_suffix}服务但停止中"
      echo -e "请按键盘任意按键返回主菜单选择 请选择4删除后重新安装并启动"
      break_end
      start_menu
    fi
  else
    install_yansir
    check_whatsapp
  fi
done

fi

  echo -e " 如果所有服务正常运行，请访问 ${Green_font_prefix}http://$current_ip:3000${Font_color_suffix}进行机器人的更多设置，注意是${Green_font_prefix}http${Font_color_suffix} 不是${Green_font_prefix}https${Font_color_suffix}"
    
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
  "lobe-chat"
)

# 检查容器是否存在并正常运行
for container in "${containers[@]}"; do
  if docker ps -a | grep -q "$container"; then
    if docker ps | grep -q "$container"; then
      echo -e " 已安装${Green_font_prefix}$container${Font_color_suffix}服务正常运行"
    else
      echo -e " ${Error}  ${Green_font_prefix}$container${Font_color_suffix}服务停止中 请重新安装并启动"
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
      break_end
      start_menu
      exit 0
fi

    
if docker network ls | grep -q "yansir-network"; then


    check_containers

    
    echo -e " 已建立${Green_font_prefix}yansir-network${Font_color_suffix}网络 正常运行"
        
else
# 网络不存在
    check_containers

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
        break_end
        start_menu
    else
        sudo curl -fsSL https://get.docker.com | sh && ln -s /usr/libexec/docker/cli-plugins/docker-compose /usr/local/bin
        sudo systemctl start docker
        sudo systemctl enable docker
        break_end
        start_menu
    fi
}

install_docker() {
    if ! command -v docker &>/dev/null; then
        install_add_docker
    else
        echo -e "${Green_font_prefix}Docker 已经安装 按键盘任意按键将返回主菜单${Font_color_suffix}"
        break_end
        start_menu
    fi
}


#升级
update_whatsapp() {

# 查找名为 “whatsapp-http-api” 的容器
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
break_end
start_menu
}


#删除lobechat
install_lobechat() {

#!/bin/bash

check_disk_space
    
    
    if ! command -v docker >/dev/null 2>&1; then
      echo "Docker 未安装，请按键盘任意键返回菜单后选择 2 安装 Docker"
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
break_end
start_menu
}
#测试IP
testgpt() {
bash <(curl -Ls IP.Check.Place)
break_end
start_menu
}


#建梯子
installvless(){
bash <(wget -qO- -o- https://github.com/233boy/sing-box/raw/main/install.sh)
echo -e " ${Red_font_prefix}请忽略上面的任何广告信息${Font_color_suffix}，${Green_font_prefix}复制上面生成的信息或者链接到你的梯子app${Font_color_suffix}"
break_end
start_menu
}

#删梯子
removevless(){
sing-box un
break_end
start_menu
}

#查找密码
findpw() {
echo
echo -e "请访问 ${Green_font_prefix}http://$current_ip:8081/db/admin/authCollection${Font_color_suffix}"
echo -e "登录用户名 ${Green_font_prefix}yansir${Font_color_suffix}"
echo -e "登录密码 ${Green_font_prefix}Ydj2qEhshAHwMnm2${Font_color_suffix}"
break_end
start_menu
}

#############系统检测组件#############
check_sys
check_version
check_disk_space
[[ "${OS_type}" == "Debian" ]] && [[ "${OS_type}" == "CentOS" ]] && echo -e "${Error} 本脚本不支持当前系统 ${release} !" && exit 1
check_whatsapp
start_menu
