# set account
# cjlupro这个账号是通用的，你如果通过portal登陆的话，不需要勾选“链接互联网”，内外网都能访问。不需要额外的闪讯/随e行。但这个校园网账号稳定性不太行，下载东西挺快的，但玩游戏还是算了。
# 用自己的账号的话，记得在账号前面加上"__", 即两个下划线，这样才是勾选“访问互联网的状态”，否则只能访问内网。联通网不需要额外客户端，但如果是电信的话，你需要在路由器上设置vpn拨号，推荐padavan。
username=cjlupro;
password=fgre984;
echo "使用账号=${username}，密码=${password}进行登录测试！";
logger -t "[AUTO LOGIN]" "使用账号=${username} 使用密码=${password} 进行登录测试！";

# set login url
url="https://192.168.100.12:801/eportal/?c=ACSetting&a=Login&wlanuserip=null&wlanacip=null&wlanacname=null&port=&iTermType=1&mac=000000000000&ip=172.28.0.197&redirect=null"
data="DDDDD=${username}&upass=${password}&R1=0&R2=&R6=0&para=00&0MKKey=123456"

# set logout url
logout_url="https://192.168.100.12:801/eportal/?c=ACSetting&a=Logout&wlanuserip=null&wlanacip=null&wlanacname=&port=&iTermType=1"

# test network
status_eth1=`curl -o /dev/null -s -w "%{http_code}\n" baidu.com`;
if [ $status_eth1 == 200 ]
then 
	echo "已连接!";
	logger -t "[AUTO LOGIN]" "已连接！";
else
# logout from current account
	echo "未连接，尝试重连!"
	logger -t "[AUTO LOGIN]" "未连接！尝试重连...!";	

	curl $logout_url --insecure
	sleep 3;

# login
	curl $url --data $data --insecure
	
	sleep 3;
	status_eth1=`curl -o /dev/null -s -w "%{http_code}\n" baidu.com`;
	if [ $status_eth1 == 200 ]
	then
		echo "已连接!";
		logger -t "[AUTO LOGIN]" "已连接！";
	fi
fi
