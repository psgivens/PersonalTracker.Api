#!/bin/sh

mb $@ &

# Wait for mb to boot and create the log file.
sleep 3

tail /mocks/mb.log -f


