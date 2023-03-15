#!/bin/bash
# 小鱼飘飘更新[2023.03.15]
# 适配了最新的校园网登录系统，优化连接体验
# 如果不需要重复运行判断，删除25行的注释符号即可
# 如果需要重复运行判断且需要自动运行，请在路由器开机运行脚本中加入"rm /var/var_running"命令
# 原作者注释：
# cjlupro这个账号是通用的，你如果通过portal登陆的话，不需要勾选“链接互联网”，内外网都能访问。不需要额外的闪讯/随e行。但这个校园网账号稳定性不太行，下载东西挺快的，但玩游戏还是算了。
# 用自己的账号的话，记得在账号前面加上"__", 即两个下划线，这样才是勾选“访问互联网的状态”，否则只能访问内网。联通网不需要额外客户端，但如果是电信的话，你需要在路由器上设置vpn拨号，推荐padavan。
username=__cjlupro;
password=fgre984;
login_url="https://192.168.100.12:802/eportal/portal/login?callback=dr1003&login_method=1&user_account=,0,${username}&user_password=${password}"
logout_url="https://192.168.100.12:802/eportal/portal/logout?callback=dr1002&login_method=1&user_account=drcom&user_password=123&ac_logout=0&register_mode=1"

function checkNetwork(){
    #ping判断连通性
    pingTest_baidu=`ping 202.108.22.5 -w 3 -c 4|grep "100% packet loss"`;
    if [ -z "$pingTest_baidu" ]
    then
        return 1;
    else
        return 0;
    fi
}

#如果不需要重复运行判断，删除下一行的注释符号即可
# rm /var/var_running

if test -e /var/var_running
then
    #上次脚本正在运行,防止多次运行
    logger -t "【自动网络状态监测】" "冲突，已取消本次更新";
else
    echo "1">"/var/var_running";
    # test network
    checkNetwork 
    if [ $? != 1 ]
    then
        checkRes=0
        count=1
        while ( test $count -le 3 )
        do
            echo "【自动网络状态监测】未检测到互联网连接，使用账号=${username}，密码=${password}登录！";
            logger -t "【自动网络状态监测】" "{第 $count 次尝试}未检测到互联网连接，使用账号=${username}，密码=${password}进行登录测试！";
            let "count++";

            logger -t "【自动网络状态监测】" "登出：${logout_url}";
            logout_result=`curl $logout_url --insecure -fsSL`;
            logger -t "【自动网络状态监测】" "${logout_result}";

            sleep 2;
            logger -t "【自动网络状态监测】" "登录：${login_url}";
            login_result=`curl ${login_url} --insecure -fsSL`;

            if [ -z `echo $login_result|grep "dr1003"` ]
            then
                echo "本次连接测试错误：请求登录API异常，返回信息${login_result}";
                logger -t "【自动网络状态监测】" "本次连接测试错误：请求登录API异常，返回信息${login_result}";
            elif [ -z `echo $login_result|grep "\"result\":1"` ]
            then
                echo "本次连接测试错误：登录API返回认证失败信息：${login_result}";
                logger -t "【自动网络状态监测】" "本次连接测试错误：登录API返回认证失败信息：${login_result}";
            else
                echo "认证通过，等待连接L2TP：${login_result}";
                logger -t "【自动网络状态监测】" "认证通过，等待连接L2TP：${login_result}";
                sleep 3;

                #约1分半，测试是否能正常连接
                ctest=0
                while (test $ctest -lt 20)
                do
                    let "ctest++"
                    checkNetwork
                    if [ $? == 1 ]
                    then
                        echo "已连接!";
                        logger -t "【自动网络状态监测】" "已连接！";
                        checkRes=1
                        break;
                    fi
                    sleep 2;
                done
            fi
            if [ $checkRes == 1 ]
            then
                break;
            fi
        done

        if [ $checkRes != 1 ]
        then
            echo "重试超时";
            logger -t "【自动网络状态监测】" "重试超过了3次，退出。等待下一次被调用";
        fi

    fi
    rm "/var/var_running";
fi