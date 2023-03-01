#!/bin/bash


# This script takes two arguments, a network address and a subnet
# mask.  It will calculate the first host address, last host address
# and the the broadcast address.  It will print the results to std 
# out.
#
# Example: 
#			./nflb.sh 192.168.2.0 255.255.255.255.240
#
#			Output:
#			Network Addres: 192.168.2.0
#			First Host:		192.168.2.1
#			Last Host:		192.168.2.14
#			Broadcast:		192.168.2.15

# echo dotted decimal ip as ' ' (space) separated list
function ipstringtoarray () {
	echo $1 | sed -r 's/\./ /g'
}


ipaddr=($(ipstringtoarray $1 ))
mask=($(ipstringtoarray $2 ))

# Output the network address

for i in {0..3}
do
	if [[ ! $i -eq 3 ]]; then
		netaddr=${netaddr}$(( ${mask[$i]} & ${ipaddr[$i]} )).
	else
		netaddr=${netaddr}$(( ${mask[$i]} & ${ipaddr[$i]} ))
	fi

done

echo "Netork Address:	$netaddr"

# find the index of the first octet which is not oxff

octetindex=0

for octet in ${mask[@]}
do
	if [[ $octet -eq 0xff ]]
	then
		octetindex=$(( $octetindex + 1 ))
	else
		break
	fi
done


# compute a mask for the host

for i in {0..3}
do
	hostmask="${hostmask}$(( (~ ${mask[$i]} + 0 ) & 0xff )) "
done

# Find the first Host Address

netaddrarr=($(ipstringtoarray $netaddr))
hostmaskarr=($hostmask)

for i in {0..3}
do
	if [ $i -lt 3 ]
	then
		firsthostaddr=${firsthostaddr}${netaddrarr[$i]}.
	else
		firsthostaddr=${firsthostaddr}$(( ${netaddrarr[$i]} +  1))
	fi
done

echo "First Host: 	$firsthostaddr"

# compute the last host and the broadcast address

for i in {0..3}
do
	if [ $i -lt 3 ]
	then
		lasthostaddr=${lasthostaddr}$(( ${netaddrarr[$i]} | ${hostmaskarr[$i]} )).
		broadcastaddr=${broadcastaddr}$(( ${netaddrarr[$i]} | ${hostmaskarr[$i]} )).
	else
		lasthostaddr=${lasthostaddr}$(( ${netaddrarr[$i]} |  (${hostmaskarr[$i]} - 1 )))
		broadcastaddr=${broadcastaddr}$(( ${netaddrarr[$i]} |  ${hostmaskarr[$i]}))
	fi
done

echo "Last Host:	$lasthostaddr"
echo "Broadcast:	$broadcastaddr"
