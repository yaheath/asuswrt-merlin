#!/bin/sh
# echo "This is a script to find the modem type out."


modem_act_path=`nvram get usb_modem_act_path`
node_home=/sys/devices
modem_enable=`nvram get modem_enable`


_find_act_type(){
	home="$node_home/"`cd $node_home && find -name "$1" 2>/dev/null`
	nodes=`cd $home && ls -d $1:* 2>/dev/null`

	got_tty=0
	got_other=0
	for node in $nodes; do
		path=`readlink -f $home/$node/driver 2>/dev/null`

		t=${path##*drivers/}
		if [ "$t" == "option" -o "$t" == "usbserial" -o "$t" == "usbserial_generic" ]; then
			got_tty=1
			continue
		elif [ "$t" == "cdc_acm" -o "$t" == "acm" ]; then
			got_tty=1
			continue
		elif [ "$t" == "cdc_ether" ]; then
			got_other=1
			echo "ecm"
			break
		elif [ "$t" == "rndis_host" ]; then
			got_other=1
			echo "rndis"
			break
		elif [ "$t" == "asix" ]; then
			got_other=1
			echo "asix"
			break
		elif [ "$t" == "qmi_wwan" ]; then
			got_other=1
			echo "qmi"
			break
		elif [ "$t" == "cdc_ncm" ]; then
			got_other=1
			echo "ncm"
			break
		elif [ "$t" == "cdc_mbim" ]; then
			got_other=1
			echo "mbim"
			break
		elif [ "$t" == "GobiNet" ]; then
			got_other=1
			echo "gobi"
			break
		fi
	done

	if [ $got_tty -eq 1 -a $got_other -ne 1 ]; then
		echo "tty"
	fi
}

type=`_find_act_type "$modem_act_path"`
if [ "$modem_enable" == "4" ]; then
	type="wimax"
# Some dongles are worked strange with QMI. e.q. Huawei EC306.
elif [ "$modem_enable" == "2" -a "$type" == "qmi" ]; then
	type="tty"
fi
echo "type=$type."

nvram set usb_modem_act_type=$type

