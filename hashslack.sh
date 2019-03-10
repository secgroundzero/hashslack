#!/bin/bash

pot_file="hashcat.potfile"
webhook_url="https://hooks.slack.com/services/XXXXXXXXXXXXXXXX"
hashcat_process="hashcat64.bin"
interval="20m"

if pgrep -x $hashcat_process > /dev/null; then
	hashes=$(wc -l < $pot_file)
	curl -X POST -H 'Content-type: application/json' --data '{"text":"New Session - Potfile: '$hashes' hashes."}' $webhook_url

	while true; do
		sleep $interval
		if pgrep -x $hashcat_process > /dev/null; then
			newhashes=$(wc -l < hashcat.potfile)
			if [ "$newhashes" -gt "$hashes" ]; then
				curl -X POST -H 'Content-type: application/json' --data '{"text":"Hash cracked! - Potfile: '$newhashes' hashes."}' $webhook_url
				hashes=$newhashes
			fi
		else
			curl -X POST -H 'Content-type: application/json' --data '{"text":"Hashcat Completed. '$hashes' hashes cracked!"}' $webhook_url
			break
		fi
	done
else

echo "Hashcat is not running!"

fi
