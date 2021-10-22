
#ifndef TSMP_PROTOCOL_H
#define TSMP_PROTOCOL_H


typedef char s8;				/**< 有符号的8位（1字节）数据定义*/
typedef unsigned char u8;		/**< 无符号的8位（1字节）数据定义*/
typedef short s16;				/**< 有符号的16位（2字节）数据定义*/
typedef unsigned short u16;	/**< 无符号的16位（2字节）数据定义*/
typedef int s32;				/**< 有符号的32位（4字节）数据定义*/
typedef unsigned int u32;		/**< 无符号的32位（4字节）数据定义*/
typedef long long s64;				/**< 有符号的64位（8字节）数据定义*/
typedef unsigned long long u64;		/**< 无符号的64位（8字节）数据定义*/


//以太网报文字段长度
#define TSMP_PROTOCOL 0xff01


/*TSMP子类型*/
typedef enum
{
	/*握手报文*/
	TSMP_ARP = 0x00,/*arp帧*/
	TSMP_BEACON = 0x01,/*beacon帧*/
	TSMP_CHIP_CFG = 0x02,/*芯片配置帧*/
	TSMP_HCP_CFG = 0x03,/*HCP配置帧*/
	TSMP_HCP_REPORT = 0x04,/*HCP状态上报帧*/
	TSMP_PTP = 0x05,/*PTP帧*/
}tsmp_sub_type;



/*TSNtag 标准格式定义*/
typedef struct
{
	u32 flow_type:3,//流类型
		flow_id:14,//静态流量使用flowID,每条静态流分配一个唯一flowID
		seq_h:15;//用于标识每条流中报文的序列号，高15位
	u16 seq_l:1,//用于标识每条流中报文的序列号，低1位
		frag_flag:1,//用于标识分片后的尾。0:分片后的中间报文	,1:尾拍
		frag_id:4,//用于表示当前分片报文在原报文中的分片序列号
		inject_addr:5,//TS流在源端等待发送调度时缓存地址
		submit_addr:5;//TS流在终端等待接收调度时缓存地址
}__attribute__((packed))tsn_tag_standard;


/*TSNtag格式转换，方便赋值*/
typedef struct
{
	u32 ctl[0];//用于网络主机序转换
	u32 seq_h:15,//用于标识每条流中报文的序列号，高15位
		flow_id:14,//静态流量使用flowID,每条静态流分配一个唯一flowID
		flow_type:3;//流类型
	u16 ctl1[0];//用于网络主机序转换
	u16 submit_addr:5,//TS流在终端等待接收调度时缓存地址
		inject_addr:5,//TS流在源端等待发送调度时缓存地址
		frag_id:4,//用于表示当前分片报文在原报文中的分片序列号
		frag_flag:1,//用于标识分片后的尾。0:分片后的中间报文	,1:尾拍
		seq_l:1;//用于标识每条流中报文的序列号，低1位
}__attribute__((packed))tsn_tag;


/*tsmp报文头部*/
typedef struct
{
	tsn_tag dmac;//dmac
	tsn_tag smac;//源mac
	u16 type; 		/* 协议类型   */
	u8 sub_type;/* TSMP协议子类型   */
	u8 inport;/* TSMP协议子类型   */
}__attribute__((packed))tsmp_header;


/*子报文头部*/
typedef struct
{
	u8 version;//版本号
	u8 type;//子报文类型，网络启动状态类型（0x20）、交换机运行状态类型（0x21）、网卡运行状态类型（0x22）
	u16 length; /* 报文数据的长度  */
	u8 tail_flag;//尾标识
	u16 imac;/* TSMP协议子类型   */
}__attribute__((packed))tsninsight_header;


/*UDP报文头部*/
typedef struct
{
	u8 dmac[6];//dmac
	u8 smac[6];//源mac
	u16 ether_type; 		/* 协议类型   */
	u16 reserve1;/* TSMP协议子类型   */
	u16 ip_len;//IP报文的总长度
	u8 reserve[8];
	
	u8 src_ip[4];
	u8 dst_ip[4];

	u16 src_port;
	u16 dst_port;
	u8 reserve3[4];
	tsninsight_header tsninsight_header_pkt;

	
}__attribute__((packed))tsninsight_udp_header;


/*上报到TSNInsight*/
typedef struct
{

	u8	port_type;//端口类型
	u16 slot_len;//时间槽长度
	u16	inj_slot_period;//注入时间槽周期
	u16	sub_slot_period;//提交时间槽周期
	u8	qbv_or_qch;//调度模式
	u16	report_period;//上报周期
	u16	report_type;//上报类型
	
	u8	report_en;//上报使能		

	u32	offset_period;//offset周期
	u16	rc_regulation_value;
	u16	be_regulation_value;
	u16	umap_regulation_value;

		
}__attribute__((packed))tsninsight_reg_report;


/*启动报文格式*/
typedef struct
{
	u16 cur_state;
	u16 state_info;
	u16 soft_version; 
	u16 hard_version;
	u8  pad[7];//补充64字节
	//tsninsight_reg_report reg_info;

}__attribute__((packed))tsninsight_start_header;



#endif


