import os
# import random
import subprocess
import re


def do_python_api():
    print('do_python_api')
    return 0


def add(a, b):
    return a + b


from scapy.layers.l2 import Ether, ARP
from scapy.utils import mac2str, atol
from scapy.all import *

local_mac = 'DA:D1:D2:D3:D4:D5'
local_ip = '192.168.1.101'
gateway_ip = '192.168.1.1'
subnet_mask = '255.255.255.0'

tx_eth = Ether(src='5A:51:52:53:54:55', dst='FF:FF:FF:FF:FF:FF')
arp = ARP(hwtype=1, ptype=0x0800, hwlen=6, plen=4, op=1,
    hwsrc='5A:51:52:53:54:55', psrc='192.168.1.100',
    hwdst='00:00:00:00:00:00', pdst='192.168.1.101')
tx_pkt = tx_eth / arp

def send_data():
    data = bytes(tx_pkt)[::-1]
    return data


def recv_res(data):
    res_byte = data.tobytes()[::-1]

    m_eth_dest_mac = res_byte[0:6]
    m_eth_src_mac = res_byte[6:12]
    m_eth_type = res_byte[12:14]
    rx_arp_payload_data = res_byte[14:42]

    rx_eth = Ether()
    rx_eth.dst = m_eth_dest_mac
    rx_eth.src = m_eth_src_mac
    rx_eth.type = int.from_bytes(m_eth_type, byteorder='big')
    
    rx_pkt = rx_eth / bytes(rx_arp_payload_data)
    rx_pkt = Ether(bytes(rx_pkt))

    # casefold可以将字符串中的大写字符转换为小写字符
    assert rx_pkt[Ether].dst.casefold() == tx_pkt[Ether].src.casefold()
    assert rx_pkt[Ether].src.casefold() == local_mac.casefold()
    assert rx_pkt[Ether].type == tx_pkt[Ether].type
    assert rx_pkt[ARP].hwtype == tx_pkt[Ether].hwtype
    assert rx_pkt[ARP].ptype == tx_pkt[Ether].ptype
    assert rx_pkt[ARP].hwlen == tx_pkt[Ether].hwlen
    assert rx_pkt[ARP].plen == tx_pkt[Ether].plen
    assert rx_pkt[ARP].op == 2
    assert rx_pkt[ARP].hwsrc.casefold() == local_mac.casefold()
    assert rx_pkt[ARP].psrc == local_ip
    assert rx_pkt[ARP].hwdst.casefold() == tx_pkt[ARP].hwsrc.casefold()
    assert rx_pkt[ARP].pdst == tx_pkt[ARP].psrc


if __name__ == '__main__':
    send_data()
    pass
