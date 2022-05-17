#! /bin/bash

# The number of terminals to open
num_terminals=4

# Set target to the ip/host specified
export target=$1
echo "Setting up attack on $target"

# Make a new directory for the ip/host specified
mkdir -p $target

# Sometimes a file browser is handy!
thunar $target

# Write our current history so our new terminals are up to date.
history -a

# open up some new terminal windows for our attack on the target.
# I acknowledge this is hacky and will find a better way to do it...later
echo "target='$target'" > /tmp/my_target

for i in $(eval echo "{1..$num_terminals}"); do
	terminator -e 'source /tmp/my_target; cd $target; /bin/bash --rcfile <(echo ". ~/.bashrc && source /tmp/my_target")'  --geometry +$((($i * 120) - 80))+$((($i * 120) - 40)) #> /dev/null
done

# One time I had the target file deleted before the last terminal could read it so...
sleep 1
rm /tmp/my_target

# Start our initial nmap scan on the target
sudo nmap -T4 -Pn -sS -A $target -oN $target/tcp1k.nmap

# Now check default vulns
sudo nmap -T4 -Pn -sS --script vuln $target -oN $target/vulns.nmap

# Rest of the TCP Range
sudo nmap -T4 -Pn -sS -A -p- $target -oN $target/tcpall.nmap

# ALWAYS check UDP. All ports takes 5ever, so just top 100 to start
sudo nmap -T4 -Pn -sU -A --top-ports 100 $target -oN $target/udp100.nmap
