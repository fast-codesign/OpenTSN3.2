/** *************************************************************************
 *  @file       basic_cfg.c
 *  @brief	    基础配置函数
 *  @date		2021/04/24 
 *  @author		junshuai.li
 *  @version	0.0.1
 ****************************************************************************/
#include "basic_cfg.h"




//extern u8 G_STATE = 0;


chip_cfg_table_info chip_cfg_table;//芯片配置的表项信息




//初始配置
int init_cfg_fun(u8 node_idx)
{
	u16 flowid_idx = 0;	
	u32 cfg_data = 0;
	u8 ret = 0;


	u8 *pkt = NULL;
	u16 type = 0;
	u16 len  = 0;
	u16 get_report_type = 0;
	u16 report = 0;
	u16 report_outport = 0;
	/*
	1表示进入基础配置状态、
	2表示基础配置状态结束，进入本地配置状态，
	3表示本地配置状态结束，进入时间同步状态，
	4表示时间同步状态结束，进入网络运行状态
	*/
	
	cfg_data = 1;
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
						CHIP_CFG_STATE_ADDR,
						1,
						(u32 *)&cfg_data);
	printf("cfg_state %d\n",cfg_data);
	//配置上报使能,开启上报
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);

	//端口类型，默认为全1
	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);

	//端口类型，默认为全1
	cfg_data = 255;
	printf("cfg port_type %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_PORT_TYPE_ADDR,1,(u32 *)&cfg_data);

	//配置上报类型默认值，上报单个寄存器	
	cfg_data = CHIP_REG_REPORT;
	printf("cfg port_type report %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_TYPE_ADDR,1,(u32 *)&cfg_data);//配置上报类型为单个寄存器上报
	
	//配置qbv_qch默认值，默认选择qch
	cfg_data = 1;
	printf("cfg qch %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_QBV_QCH_ADDR,1,&cfg_data);	

	//配置上报使能,开启上报
	cfg_data = 1;
	printf("cfg report enable %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_EN_ADDR,1,(u32 *)&cfg_data);


	//配置上报周期默认值，为1ms
	cfg_data = 1;
	printf("cfg report period %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_PERIOD_ADDR,1,(u32 *)&cfg_data);//配置端口类型

	//配置完成寄存器默认值2，可以传输非ST流
	cfg_data = 2;
	printf("cfg finish %d\n",cfg_data);
	build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_CFG_FINISH_ADDR,1,(u32 *)&cfg_data);//配置端口类型


	//配置转发表，每次配置一个，配置多次
	for(flowid_idx=0;flowid_idx<init_cfg[node_idx].forward_table_num;flowid_idx++)
	{
		//printf("node_idx %d,init_cfg[node_idx].forward_table_num %d\n",node_idx,init_cfg[node_idx].forward_table_num);
		//printf("cfg forward flowID %d,outport %d\n", init_cfg[node_idx].forward_table[flowid_idx].flowid,init_cfg[node_idx].forward_table[flowid_idx].outport);
		cfg_data = init_cfg[node_idx].forward_table[flowid_idx].outport;
		//配置转发表，每次配置一个，配置多次
		build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_FLT_BASE_ADDR + init_cfg[node_idx].forward_table[flowid_idx].flowid,
								1,
								(u32 *)&cfg_data);

#if 1			
		report = CHIP_FLT_REPORT_BASE + (init_cfg[node_idx].forward_table[flowid_idx].flowid)/32;
		build_send_chip_cfg_pkt(init_cfg[node_idx].imac,CHIP_REPORT_TYPE_ADDR,1,&report);//配置上报类型为转发表的上报类型

		while(1)
		{
			
			//printf("wait cfg basic forward report pkt\n");
			//printf("************cfg type = %x********************\n",CHIP_FLT_BASE_ADDR);
			pkt = data_pkt_receive_dispatch_1(&len);
			if(pkt != NULL) 
			{
				//printf("get report pkt\n");
			}
			else
			{
				//printf("have no pkt\n");
				continue;
			}
			if(*(pkt+12)==0xff && *(pkt+13)==0x01) 
			{
				printf("get report pkt\n");
			
				//printf("len %d\n",len);
				get_report_type = *(pkt + len -2);
				//printf("get_report_type %d\n",get_report_type);
				get_report_type = get_report_type<<8;
				
				//printf("get_report_type %d\n",get_report_type);
				get_report_type = get_report_type + *(pkt + len -1);			
				printf("get_report_type %d\n",get_report_type);
				
				if(*(pkt+14) == TSMP_BEACON && get_report_type == report)
				{
					pkt = pkt + DATA_OFFSET;
					pkt = pkt + ((init_cfg[node_idx].forward_table[flowid_idx].flowid)%32)*2;//求余
					report_outport = *pkt;
					//printf("*pkt %d,*(pkt+1) %d\n",*pkt,*(pkt+1));
					report_outport = report_outport<<8;
					
					report_outport = report_outport + *(pkt+1);		
					if(report_outport == init_cfg[node_idx].forward_table[flowid_idx].outport)
					{
					
						printf("cfg forward success\n");
						printf("flowid = %d,cfg outport = %d,report_outport = %d\n",init_cfg[node_idx].forward_table[flowid_idx].flowid,init_cfg[node_idx].forward_table[flowid_idx].outport,report_outport);
						break;
					}
					else
					{
						printf("cfg forward fail\n");
						printf("flowid = %d,cfg outport = %d,report_outport = %d\n",init_cfg[node_idx].forward_table[flowid_idx].flowid,init_cfg[node_idx].forward_table[flowid_idx].outport,report_outport);

						//return -1;
					}
				}
				else
				{
					printf("report type error,report type = %d\n",get_report_type);
				}
			}
			else
			{
				
				//printf("%d %d report chip table pkt error\n",report,get_report_type);
				printf("report chip table pkt error\n");
			}
			
		}
#endif
	}
	int i =0;
	//如果设置模式为qbv模式，则需要门控全开
	if(init_cfg[node_idx].reg_data.qbv_or_qch == 0)
	{
		//配置默认门控表，BE门控全开
		//memset(&chip_cfg_table,255,sizeof(chip_cfg_table));
		for(i=0;i<16384;i++)
		{
			chip_cfg_table.table[i] = 255;

		}
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC0_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC1_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC2_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC3_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC4_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC5_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC6_BASE_ADDR,chip_cfg_table);
		cfg_chip_table(init_cfg[node_idx].imac,CHIP_QGC7_BASE_ADDR,chip_cfg_table);
		
	}


	//init_cfg[node_idx].reg_data.port_type = 255;
	//init_cfg[node_idx].reg_data.report_en = 1;
	//init_cfg[node_idx].reg_data. = 0;

	
	init_cfg[node_idx].reg_data.cfg_finish = 2;
	init_cfg[node_idx].reg_data.report_enable = 1;
	init_cfg[node_idx].reg_data.report_period = 1;

	init_cfg[node_idx].reg_data.report_low  = 0;
	init_cfg[node_idx].reg_data.report_high = 0;

	init_cfg[node_idx].reg_data.cfg_state = 1;
	//配置所有的单个寄存器
	ret = cfg_chip_single_register(init_cfg[node_idx].imac,init_cfg[node_idx].reg_data);
	






	cfg_data = 2;
	printf("cfg hcp state %d\n",cfg_data);	
	//build_send_hcp_cfg_pkt(init_cfg[node_idx].imac,HCP_STATE_ADDR,(u32 *)&cfg_data,1);

	cfg_data = init_cfg[node_idx].reg_data.port_type;	
	printf("cfg hcp port_type %d\n",cfg_data);	
	//build_send_hcp_cfg_pkt(init_cfg[node_idx].imac,HCP_PORT_TYPE_ADDR,(u32 *)&cfg_data,1);
	//初始配置结束


	return 0;
}

int init_test_fun()
{
	u16 flowidtest_idx=0;
	u32 test_data=0;
	u8 test_idx = 0;


    for(test_idx;test_idx<cur_test_num;test_idx++)
	{
		//printf("xunhuan9898989898989\n");

		test_data =init_test[test_idx].time_slot;
		printf("inject slot period %d\n",test_data);		
		build_send_chip_cfg_pkt(init_test[test_idx].imac,CHIP_TIME_SLOT_ADDR,1,(u32 *)&test_data);

		test_data = init_test[test_idx].inject_slot_period;
		printf("test slot %d\n",test_data);
		build_send_chip_cfg_pkt(init_test[test_idx].imac,CHIP_INJECT_SLOT_PERIOD_ADDR,1,(u32 *)&test_data );


		test_data = 1;
		build_send_chip_cfg_pkt(init_cfg[test_idx].imac,
							CHIP_CFG_STATE_ADDR,
							1,
							(u32 *)&test_data);

	}

     //printf("xunhuan end\n");
     return 0;
}

u16 get_imac_from_tsntag(u8 *tsntag)
{
	u16 temp_imac = 0;
	u8 temp_data = 0;
	temp_data = *(tsntag+2);
	temp_imac = temp_data >> 7;
	
	temp_data = *(tsntag+1);
	temp_imac += temp_data * 2;
	
	temp_data = *tsntag;
	temp_imac += (temp_data&0x1f)  * 512;

	return temp_imac;
}

u8 node_idx = 0;//节点的索引值
u8 local_cfg_flag = 1;

u8 nic_num = 7;

int send_start_report_tsninsight(u16 cur_state,u16 state_info,u16 imac)
{
	//构建和发送上报报文			
	printf("send TSNInsight report\n");
	u16 *pkt = NULL;
	u8 i  = 0;
	tsninsight_start_header *reg_report_info = NULL;
	reg_report_info = (tsninsight_start_header *)build_tsninsight_pkt(sizeof(tsninsight_start_header),0x20,0);
	reg_report_info->cur_state	= ntohs(cur_state);//基础配置状态
	reg_report_info->state_info = ntohs(state_info);//基础配置成功
	reg_report_info->soft_version = ntohs(0x30);//软件版本
	reg_report_info->hard_version = ntohs(0x32);//硬件版本
	for(i=0;i<8;i++)
		reg_report_info->pad[i] = 0;

	//对imac进行赋值
	pkt = (u16 *)reg_report_info;
	pkt = pkt - 1;
	*pkt = ntohs(imac);
	
	lo_data_pkt_send_handle((u8 *)reg_report_info,sizeof(tsninsight_start_header));	
	return 0;
}


u16 basic_cfg_report_num = 0;


u8 flag_file_open_num = 0;
void fwrite_file(u16 imac,u64 hw_version)
{
	FILE *fp = NULL;

	u8 buf[100] = {0};
	if(flag_file_open_num == 0)
	{
		fp = fopen("./version.txt", "w");
		flag_file_open_num++;
	}		
	else
		fp = fopen("./version.txt", "a+");
	sprintf(buf, "%s\n", "*************************");
	fwrite(buf, sizeof(char), strlen(buf), fp);
	
	sprintf(buf, "imac = 0x%x\n", imac);
	fwrite(buf, sizeof(char), strlen(buf), fp);
	
	sprintf(buf, "version = 0x%llx\n", hw_version);
	fwrite(buf, sizeof(char), strlen(buf), fp);
	fclose(fp);
}


int basic_cfg(u8 *pkt,u16 pkt_len)
{
	
	
	int ret = 0;
	u16 imac = 0;//节点的imac地址
	chip_reg_info *temp_reg = NULL;//节点上报的单个寄存器	

	u8 *temp_pkt = NULL;//

	u16 flowid_idx = 0;

	u32 cfg_data = 0;

	u8 nic_idx = 0;

	//首先判断是否接收到与控制器直连节点的上报报文
	if(*(pkt+12)==0xff && *(pkt+13)==0x01) 
	{
		printf("get report pkt\n");
		basic_cfg_report_num++;
		//printf("basic_cfg_report_num %d\n",basic_cfg_report_num);
		if(basic_cfg_report_num > 100)
		{
			printf("basic cfg fail\n");
			send_start_report_tsninsight(1,0,init_cfg[node_idx].imac);//基础状态，基础状态失败，imac表示配置失败的节点
			return -1;
		}
		imac = get_imac_from_tsntag(pkt+6);
		//printf("*(pkt+8) %d\n",*(pkt+8));
		//判断上报的节点类型
		if(imac == init_cfg[node_idx].imac)
		{
			printf("get imac = %d report\n",imac);
			temp_pkt = pkt+16;//偏移到数据域，16字节TSMP头
			host_to_net_single_reg(temp_pkt);//网络序转主机序函数
			
			//强制转换
			temp_reg = (chip_reg_info *)temp_pkt;
			//打印上报单个寄存器的内容
			printf_single_reg(temp_reg);
		}
		else
		{
			printf("report pkt imac error imac=%d\n",imac);
			printf("cfg pkt imac =%d\n",init_cfg[node_idx].imac);

			return 0;
		}
		
		//判断上报内容是否正确
		if(init_cfg[node_idx].reg_data.slot_len == temp_reg->slot_len && init_cfg[node_idx].reg_data.cfg_finish == temp_reg->cfg_finish)
		{
			printf("slot_len cfg_finish cfg success\n");
			
			//最后配置关闭该节点的上报功能
			cfg_data = 0;
			printf("cfg  report enable %d\n",cfg_data);	
			build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_REPORT_EN_ADDR,
								1,
								(u32 *)&cfg_data);

			//最后配置端口类型，开始端口类型为全1，配置完该节点后，接收配置的报文的端口需要配置为0
			cfg_data = init_cfg[node_idx].reg_data.port_type;
			printf("cfg  port_type %d\n",cfg_data); 
			build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_PORT_TYPE_ADDR,
								1,
								(u32 *)&cfg_data);

			cfg_data = 2;
			build_send_chip_cfg_pkt(init_cfg[node_idx].imac,
								CHIP_CFG_STATE_ADDR,
								1,
								(u32 *)&cfg_data);

			fwrite_file(imac,temp_reg->hw_version);
			

			//printf("888888888888888888888888888888888888888888888888888888888888888888888888888888cur_node_num %d\n",cur_node_num);
			//配置结束
			if(node_idx >= (cur_node_num-1))//last  is nic 
			{

								//配置上报使能,开启上报
#if 0
				for(nic_idx=1;nic_idx<=nic_num;nic_idx++)
				{
				cfg_data = init_cfg[node_idx+nic_idx].reg_data.slot_len;
				printf("cfg slot len %d\n",init_cfg[node_idx+nic_idx].reg_data.slot_len);
				build_send_chip_cfg_pkt(init_cfg[node_idx+nic_idx].imac,CHIP_TIME_SLOT_ADDR,1,(u32 *)&cfg_data);

				//端口类型，默认为全1
				cfg_data = init_cfg[node_idx+nic_idx].reg_data.inj_slot_period;
				printf("cfg inj_slot_period %d\n",cfg_data);
				build_send_chip_cfg_pkt(init_cfg[node_idx+nic_idx].imac,CHIP_INJECT_SLOT_PERIOD_ADDR,1,(u32 *)&cfg_data);

				}
#endif				

				ret = init_test_fun(); 
 				if(ret==-1)
 				{
	 					printf("init_test_fun fail\n");
						return -1;
				}
				
				//配置结束，跳转状态
				printf("basic cfg end\n");

				//构建和发送上报报文
				send_start_report_tsninsight(1,1,0);//基础状态，基础状态成功，imac填充默认值0

					
				if(local_cfg_flag == 1)
					G_STATE = LOCAL_PLAN_CFG_S;
				else
					G_STATE = REMOTE_PLAN_CFG_S;
				
			}
			else//配置未结束，配置下一个节点
			{
				
				printf("cfg next node\n");
				basic_cfg_report_num = 0;
				node_idx++;
				init_cfg_fun(node_idx);
			}

		}
		else
		{
			printf("report pkt data error\n");
			return 0;
		}
		
	}
	else
	{
		printf("report pkt type error\n");
		basic_cfg_report_num++;
		//printf("basic_cfg_report_num %d\n",basic_cfg_report_num);
		if(basic_cfg_report_num > 100)
		{
			printf("basic cfg fail\n");
			send_start_report_tsninsight(1,0,init_cfg[node_idx].imac);//基础状态，基础状态失败，imac表示配置失败的节点
			return -1;
		}
		
	}
		
		
}
		
