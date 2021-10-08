/** *************************************************************************
 *  @file       main.c
 *  @brief	    TSNLight主函数
 *  @date		2021/05/07 
 *  @author		junshuai.li
 *  @version	3.0.6 
 修改人：李军帅
 该版本是在32节点的3.0的版本下修改的，主要修改的内容包含以下
version3.0.1
1、增加使用本地回环网卡通信接口，
2、在每个状态要跳变时发送状态信息
3、在运行状态，每接收到状态信息则上报状态信息
4、屏蔽在解析xml文本的打印信息
5、该版本中不能出现测试仪，因为测试仪没有上报，但需要同步				  
 ****************************************************************************
 version3.0.2
1、在从lo回环网口发送报文后，增加释放的函数，释放内存
****************************************************************************
 version3.0.3 修改人：李军帅
1、在主函数中增加判断如果为本地基础配置状态，不管是否接收到报文，都会调用本地配置函数
	进行本地配置
****************************************************************************
 version3.0.4 修改人：李军帅
1、在ptp函数里面，修改所有的节点没有同步完成前就跳转到下一个状态的bug，增加一个同步的次数进行判断
****************************************************************************
 version3.0.5 修改人：赵宇晨修改，李军帅汇总上传    日期：2021/09/07
1、提取测试仪的配置信息，在初始配置中添加test标签表示测试仪，在初始状态下解析和存储，
	在基础配置状态下进行配置测试仪
****************************************************************************
 version3.0.6 修改人：李军帅	 日期：2021/09/07
1、增加对配置状态寄存器的配置，	
	1表示进入基础配置状态、							 2表示基础配置状态结束，进入本地配置状态，
	3表示本地配置状态结束，进入时间同步状态，4表示时间同步状态结束，进入网络运行状态
2、修改上报寄存器的数据结构，添加配置状态寄存器和硬件版本寄存器
****************************************************************************
 version3.0.7 修改人：李军帅  日期：2021/09/13
1、添加把硬件版本写入version文本，	
2、增加配置验证功能，默认打开配置验证
3、在配置验证时，初始化门控时只初始化前四个端口，因为千兆后四个端口不存在，无法进行验证
4、针对百兆修改阈值问题，配置的阈值表示BE流阈值，RC流阈值为BE流阈值-8
5、修改对测试仪配置时，时间槽的地址和调度周期地址错误的问题
****************************************************************************
 version 2021092401 修改人：李军帅  日期：2021/09/24
1、增加错误写入debug_error.txt文件，
	主要错误为同步周期偏差大于设置偏差的两倍，
	时间同步精度大于阈值12拍，在
	网络运行状态未接收到本次同步的sync或req报文	
2、在基础配置超时函数中修改由#if1变为#if0
****************************************************************************/


#include "cnc_api/include/cnc_api.h"
#include "basic_cfg/basic_cfg.h"
#include "local_cfg/local_cfg.h"
#include "net_init/net_init.h"
#include "remote_cfg/remote_cfg.h"
#include "state_monitor/state_monitor.h"
#include "ptp/ptp_single_process.h" 
#include "arp_proxy/arp_proxy.h"




int restart_num = 0;
int work_run = 1;


struct timeval state_tv;//网络运行状态的时间戳
struct timeval basic_tv;//基础配置状态的时间戳
struct timeval local_tv;//本地配置状态的时间戳



void basic_cfg_timeout_handle(struct timeval tv)
{


	//printf("basic_cfg_timeout_handle111\n");
	if(basic_tv.tv_sec == 0)
	{
		//第一次开始定时
		basic_tv.tv_sec = tv.tv_sec;
	}
	else
	{
	#if 0
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - basic_tv.tv_sec > 5)
		{
			printf("error:basic cfg timeout\n");
			basic_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
			restart_num = 4;//退出程序
		}
	#endif
	}

}

void local_cfg_timeout_handle(struct timeval tv)
{

	printf("local_cfg_timeout_handle\n");
	if(local_tv.tv_sec == 0)
	{
		//第一次开始定时
		local_tv.tv_sec = tv.tv_sec;
	}
	else
	{
		#if 0
		//判断是否超出最大基础配置时间
		if(tv.tv_sec - local_tv.tv_sec > 100)
		{
			printf("error:basic cfg timeout\n");
			local_tv.tv_sec = 0;//初始基础配置时间
			work_run = 0;//超时
		}
		#endif
	}
	
}

void remote_cfg_timeout_handle(struct timeval tv)
{
#if 0
	u8 pkt[128];
	memset(pkt,0,128);
	pkt[6] = 0x60;
	pkt[7] = 0x00;
	pkt[34] = 0x1f;
	pkt[35] = 0x90;
	pkt[36] = 0x1f;
	pkt[37] = 0x90;	
	
	//类型
	pkt[43] = 0x0c;
	//长度
	pkt[44] = 0x00;
	pkt[45] = 0x28;		
	//tail
	pkt[46] = 0x01;
	
	//imac
	pkt[47] = 0x00;
	pkt[48] = 0x01;
	
	//reg
	pkt[49] = 0x00;
	pkt[50] = 0x02;	
	pkt[51] = 0x00;
	pkt[52] = 0x01;	
	
	//映射表
	pkt[49] = 0xc0;
	pkt[50] = 0xa8;	
	pkt[51] = 0x01;
	pkt[52] = 0x02;	

	pkt[53] = 0xc0;
	pkt[54] = 0xa8;	
	pkt[55] = 0x01;
	pkt[56] = 0x03;		

	pkt[57] = 0x80;
	pkt[58] = 0x80;	

	pkt[59] = 0x70;
	pkt[60] = 0x70;

	pkt[61] = 0x11;	
	
	//流类型
	pkt[62] = 0x03;
	pkt[63] = 0x01;
	pkt[64] = 0x01;
	
	pkt[65] = 0x00;
	pkt[66] = 0x01;
	
	pkt[67] = 0x00;
	pkt[68] = 0x01;
	
	printf("start remote cfg\n");
	remote_cfg(pkt);
	G_STATE = SYNC_INIT_S;
#endif	
}

void cfg_verify_timeout_handle(struct timeval tv)
{
	G_STATE = SYNC_INIT_S;
}


int time_handle(int global_state,struct timeval tv)
{
	u16 ret = 0;
    switch(global_state)//根据状态判断需要进行的超时处理逻辑
    {
        case  BASIC_CFG_S:basic_cfg_timeout_handle(tv);break;
        //网络基础配置
        
        case  LOCAL_PLAN_CFG_S:local_cfg_timeout_handle(tv);break;
			
        //本地规划配置

        case  REMOTE_PLAN_CFG_S:remote_cfg_timeout_handle(tv);break;
        //远程规划配置

        case  CONF_VERIFY_S:cfg_verify_timeout_handle(tv);break;
        //配置验证

        case  SYNC_INIT_S:
		{	
			//printf("88888\n");
			sync_period_timeout();
			break;//时间同步初始化
		}
        case  NW_RUNNING_S:
		{
			//printf("NW RUNNING S timeout handle\n");
		    //时间同步，状态监测，动态配置
			sync_period_timeout();	
			ret = state_monitor_timeout(tv);
			if(ret == 255)
				return -1;
/*
			if(state_tv.tv_sec == 0)
			{
				//第一次开始定时
				state_tv.tv_sec = tv.tv_sec;
			}
			else
			{
				if(tv.tv_sec - state_tv.tv_sec > 10)
				{
					//send_remote_state();//发送上报状态
					state_tv.tv_sec = tv.tv_sec;//更新当前时间
				}
			}
*/			
			break;
		}

    }
}

void net_run(u8 *pkt,u16 pkt_length)
{
	
	//dynamic_remote_cfg(pkt,pkt_length);	
#if 1	
    u8 pkt_type = get_pkt_type(pkt,pkt_length);
    if(pkt_type == 0x05)
    {
		//printf("***********************************ptp handle get pkt223\n");
        ptp_handle(pkt_length,pkt);
    }  
    else if(pkt_type == 0x01)
    {
		//printf("***********************************state monitor get pkt224\n");
        state_monitor(pkt_length,pkt);
    }  
    else if(pkt_type == 0x00)
    {
		//printf("************************************arp reply get pkt225\n");
        arp_reply(pkt_length,pkt);
    }
#endif
}

int cfg_varify(u8 *pkt)
{
	
	return 0;
}


void create_debug_file()
{
	FILE *fp;
	char str[] = "****** error message ******\n";
	fp = fopen("debug_error.txt","w");
	fwrite(str,sizeof(char),strlen(str),fp);
	fclose(fp);
	return;
}

int main(int argc,char* argv[])
{
	int ret = 0;
	//初始化进程
	char test_rule[64] = {0};
	char temp_net_interface[16]={0};

	u16 imac = 0;
	u64 sw_version = 0x2021092401;

	
	struct timeval cur_time;//用于获取当前时间
	u16 pkt_len  = 1;//报文长度
	u8 *pkt      = NULL;//报文的指针

	fwrite_file(imac,sw_version);

	create_debug_file();

	//u8 debug_buf[100];
	//sprintf(debug_buf,"test pkt_len = %s",pkt_len);
	//write_debug_msg("test pkt_len = %d\n",pkt_len);
	//write_debug_msg("test1 pkt_len = %d\n",pkt_len);

	if(argc != 2)
	{
		printf("input format:./tsnlight net_interface\n");
		return 0;
	}

	//libpcap initialization
	sprintf(temp_net_interface,"%s",argv[1]);

	data_pkt_receive_init(test_rule,temp_net_interface);//数据接收初始化
	data_pkt_send_init(temp_net_interface);//数据发送初始化
	lo_data_pkt_send_init();//数据发送初始化,初始化回环网口

init:
    net_init(temp_net_interface);
	//init_cfg_fun(1);
	printf("enter while 1 G_STATE %d\n",G_STATE);
    while(1)
    {
		//每次获取一个报文
        pkt = data_pkt_receive_dispatch_1(&pkt_len);
       
        if(pkt != NULL)
        {
            switch(G_STATE)//根据状态判断需要进行的处理逻辑
            {
	            case  BASIC_CFG_S:		ret = basic_cfg(pkt,pkt_len);break;		
	            case  LOCAL_PLAN_CFG_S: local_cfg(pkt,pkt_len);break;
	            case  REMOTE_PLAN_CFG_S:remote_cfg(pkt,pkt_len);break;
	            case  CONF_VERIFY_S:	cfg_varify(pkt);break;
	            case  SYNC_INIT_S:		ptp_handle(pkt_len,pkt);break;
	            case  NW_RUNNING_S:		net_run(pkt,pkt_len);break;
            } 
        }
		else if(pkt == NULL && G_STATE == LOCAL_PLAN_CFG_S)
		{
			local_cfg(pkt,pkt_len);
		}
		
		if(ret == -1)
		{
			printf("TSNLight eixt\n");
			return 0;

		}
			
		
        gettimeofday(&cur_time,NULL);//获取当前时间，用于判断是否超时
        ret = time_handle(G_STATE,cur_time);//根据本地时间判断是否超时
		if(ret == -1)
		{
			printf("ptp fail\n");
			return 0;
        }

        if(work_run==1) //判断网络是否正常工作，该标志位在时间处理函数更改
            continue;
        else
        {
        	work_run = 1;
			goto init;//跳转到初始状态
		}
            
        if(restart_num>3)//判断重启是否超过三次
            break;
        else
            continue;
    }
	return 0;
}




