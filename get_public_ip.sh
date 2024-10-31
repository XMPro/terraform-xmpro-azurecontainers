#!/bin/bash
echo "{\"public_ip\": \"$(curl -s https://ifconfig.me)\"}"
