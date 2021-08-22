#!/bin/bash

# Install service
mkdir -p $HOME/.local/share/systemd/user
cp stonkboard.service $HOME/.local/share/systemd/user/.
systemctl --user enable stonkboard.service

echo "Run 'systemctl --user start stonkboard' to start."
