#!/bin/bash
stty erase ^H

red='\e[91m'
green='\e[92m'
yellow='\e[94m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n ��ʹ�� ${red}root ${none}�û����� ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

case $sys_bit in
'amd64' | x86_64) ;;
*)
    echo -e " 
	 ��� ${red}��װ�ű�${none} ��֧�����ϵͳ�� ${yellow}(-_-) ${none}

	��ע: ��֧�� Ubuntu 16+ / Debian 8+ / CentOS 7+ ϵͳ
	" && exit 1
    ;;
esac

if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

    if [[ $(command -v yum) ]]; then

        cmd="yum"

    fi

else

    echo -e " 
	 ��� ${red}��װ�ű�${none} ��֧�����ϵͳ�� ${yellow}(-_-) ${none}

	��ע: ��֧�� Ubuntu 16+ / Debian 8+ / CentOS 7+ ϵͳ
	" && exit 1

fi

if [ ! -d "/etc/ethdefee/" ]; then
    mkdir /etc/ethdefee/
fi

error() {
    echo -e "\n$red �������$none\n"
}

install_download() {
		installPath="/etc/ethdefee"
    if [[ $cmd == "apt-get" ]]; then
        $cmd install -y supervisor
        service supervisor restart
    else
        $cmd install -y epel-release
        $cmd update -y
        $cmd install -y supervisor
        systemctl enable supervisord
        service supervisord restart
    fi
    [ -d ./ethdefee ] && rm -rf ./ethdefee
    git clone https://github.com/why123bs/ethdefee.git

    if [[ ! -d ./ethdefee ]]; then
        echo
        echo -e "$red ��¡�ű��ֿ������...$none"
        echo
        echo -e " �볢�����а�װ Git: ${green}$cmd install -y git $none ֮���ٰ�װ�˽ű�"
        echo
        exit 1
    fi
    cp -rf ./ethdefee /etc/
    if [[ ! -d $installPath ]]; then
        echo
        echo -e "$red �����ļ�������...$none"
        echo
        echo -e " ʹ�����°汾��Ubuntu����CentOS������"
        echo
        exit 1
    fi
}


start_write_config() {
    echo
    echo "������ɣ������ػ�"
    echo
    chmod a+x $installPath/ethdefee
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ethdefee.conf -f
        echo "[program:ethdefee]" >>/etc/supervisor/conf/ethdefee.conf
        echo "command=${installPath}/ethdefee" >>/etc/supervisor/conf/ethdefee.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf/ethdefee.conf
        echo "autostart=true" >>/etc/supervisor/conf/ethdefee.conf
        echo "autorestart=true" >>/etc/supervisor/conf/ethdefee.conf
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ethdefee -f
        echo "[program:ethdefee]" >>/etc/supervisor/conf.d/ethdefee.conf
        echo "command=${installPath}/ethdefee" >>/etc/supervisor/conf.d/ethdefee.conf
        echo "directory=${installPath}/" >>/etc/supervisor/conf.d/ethdefee.conf
        echo "autostart=true" >>/etc/supervisor/conf.d/ethdefee.conf
        echo "autorestart=true" >>/etc/supervisor/conf.d/ethdefee.conf
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ethdefee.ini -f
        echo "[program:ethdefee]" >>/etc/supervisord.d/ethdefee.ini
        echo "command=${installPath}/ethdefee" >>/etc/supervisord.d/ethdefee.ini
        echo "directory=${installPath}/" >>/etc/supervisord.d/ethdefee.ini
        echo "autostart=true" >>/etc/supervisord.d/ethdefee.ini
        echo "autorestart=true" >>/etc/supervisord.d/ethdefee.ini
    else
        echo
        echo "----------------------------------------------------------------"
        echo
        echo " Supervisor��װĿ¼û�ˣ���װʧ��"
        echo
        exit 1
    fi
    
    
    
    if [[ $cmd == "apt-get" ]]; then
        ufw allow 18888
    else
        firewall-cmd --zone=public --add-port=18888/tcp --permanent
    fi    
    if [[ $cmd == "apt-get" ]]; then
        ufw reload
    else
        systemctl restart firewalld
    fi
    
    
    changeLimit="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 204800" >>/etc/security/limits.conf
        changeLimit="y"
    fi
    if [ $(grep -c "root hard nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root hard nofile 204800" >>/etc/security/limits.conf
        changeLimit="y"
    fi

    clear
    echo
    echo "----------------------------------------------------------------"
    echo
	if [[ "$changeLimit" = "y" ]]; then
	  echo "${red} ϵͳ�����������Ѿ����ˣ������һ�����б�������Ҫ����${none}"
	  echo
	fi
    supervisorctl reload
    echo "��������ǽ�˿�18888�Ѿ����ţ�������޷����ӣ��뵽�Ʒ����̿���̨������ȫ�飬���ж�Ӧ�Ķ˿�"
    echo "���Է��ʱ���IP:18888"
    echo
    echo "��װ���...�ػ�ģʽ����־����Ҫ��־������ nohup ./web &  ��ʽ����"
		echo
		echo "���������ļ���/etc/ethdefee/config.yml����ҳ�˿��޸ĵ�¼����token"
    echo
    echo "[*---------]"
    sleep  1
    echo "[**--------]"
    sleep  1
    echo "[***-------]"
    sleep  1
    echo "[****------]"
    sleep  1
    echo "[*****-----]"
    sleep  1
    echo "[******----]"
    cat /etc/ethdefee/config.yml
    echo
    echo "----------------------------------------------------------------"
    
    
    
}



uninstall() {
    clear
    if [ -d "/etc/supervisor/conf/" ]; then
        rm /etc/supervisor/conf/ethdefee.conf -f
    elif [ -d "/etc/supervisor/conf.d/" ]; then
        rm /etc/supervisor/conf.d/ethdefee.conf -f
    elif [ -d "/etc/supervisord.d/" ]; then
        rm /etc/supervisord.d/ethdefee.ini -f
    fi
    supervisorctl reload
    echo -e "$yellow �ѹر�������${none}"
}

clear
while :; do
    echo
    echo "....... ethdefee һ����װ�ű� ......."
    echo
    echo " 1. ��ʼ��װ + �Զ�����"
    echo
    echo " 2. ֹͣ + �ر��Զ�����"
    echo
    read -p "$(echo -e "��ѡ�� [${magenta}1-2$none]:")" choose
    case $choose in
    1)
        install_download
        start_write_config
        break
        ;;
    2)
    
        uninstall
        break
        ;;
    *)
        error
        ;;
    esac
done
