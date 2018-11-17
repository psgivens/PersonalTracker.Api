#!/bin/sh

mb $@ &

# Wait for mb to boot and create the log file.
sleep 1

tail /mocks/mb.log -f


