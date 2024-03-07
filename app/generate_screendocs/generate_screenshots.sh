#!/bin/bash

read -p "Enter username: " username
read -p "Enter password: " password

flutter drive \
  --driver=generate_screendocs/test_driver.dart \
  --target=generate_screendocs/screenshot_sequence.dart \
  --dart-define=TEST_USER="$username" \
  --dart-define=TEST_PASSWORD="$password"
