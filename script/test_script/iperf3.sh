

# client side
iperf3 -c 192.168.27.60 -p 7777 -b 0 -i 60 -n 10000000000000000000000000

# server side
iperf3 -s -p 7777 -f M -i 60
