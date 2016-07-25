#!/bin/bash

# Script that takes command line input - the domain name - and outputs it's SSL information
# Allen Vailliencourt
# July 25, 2016

echo "This script uses OpenSSL to query cert information on the domain name you input"
echo

# functions
options() {
  echo "Do you want to..."
  echo "full SSL (q)uery a domain name"
  echo "name, (e)xpiration only"
  echo "e(x)it the script"
  read -p "Choose one: " OPTION

  case $OPTION in
    "q")
    sslquery
    echo
    options
    ;;
    "e")
    sslquery_expiration
    echo
    options
    ;;
    "x")
    echo "Thanks for using the script. Have a good day."
    exit
    ;;
  esac
}

sslquery() {
  # Taken from this post/answer - http://serverfault.com/questions/661978/displaying-a-remote-ssl-certificate-details-using-cli-tools
  echo
  read -p "Enter domain name to query: " URL
  echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -inform pem -noout -text
}

sslquery_expiration() {
  echo
  read -p "Enter domain name to query: " URL
  echo | openssl s_client -showcerts -servername $URL -connect $URL:443 2>/dev/null | openssl x509 -inform pem -subject -issuer -dates -noout
}

options
