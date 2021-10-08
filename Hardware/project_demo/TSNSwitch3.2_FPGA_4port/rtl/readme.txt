本目录下的rtl文件是TSNSwitch3.2的网络接口数目相关文件和器件相关文件，此示例工程是实例化4个网络接口的TSN交换机工程。本目录中各个文件说明如下：
1.网络接口数目相关文件
TSSwitch.v:                              调用network_input_process_top.v和network_output_process.v
TSSwitch_top.v:                        调用TSSwitch.v，并根据网络接口数目实例化对应数量的gmii_adapter
2.器件相关文件
除network_input_process_top.v，network_output_process.v，TSSwitch.v，TSSwitch_top.v外，其他文件均为器件相关文件。