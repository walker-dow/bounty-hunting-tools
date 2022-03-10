#! /usr/bin/env python3

import dns.resolver
import dns.query

targetDomain = input("Please enter a domain to attempt zonetransfer on: ")

# Get nameserver(s):
nameServersObject = dns.resolver.resolve(targetDomain, 'NS')

# For each entry in the nameservers object, remove the trailing '.' and resolve the IP
for entry in nameServersObject:
    nameServer = str(entry)[0:-1]    
    nsIPObject = dns.resolver.resolve(nameServer)
    
    # For each nameserver IP in the nameserve IP object, attempt a zone transfer,
    # store in a transfer attempt object if successful.
    for nsIP in nsIPObject:
        try:
            transferAttemptObject = dns.query.xfr(str(nsIP), targetDomain)

            # For each chunk of info we received, print the info.
            for transferInfo in transferAttemptObject:
                printStr = "\nZone Transfer attempt for {} nameserver ip {}:".format(targetDomain, nsIP)
                print(printStr)
                print("-" * ( len(printStr) - 1))
                print(transferInfo)
        except:
            print("\nZone Transfer attempt failed for {} nameserver ip {}.".format(targetDomain, nsIP))
