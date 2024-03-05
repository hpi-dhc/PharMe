#!/bin/bash

output_directory="../docs/screencasts/"
cuts_log_path="${output_directory}cuts.log"
test_log_path="${output_directory}test.log"
full_video_path="${output_directory}full.mov"

read -p "Enter username: " username
read -p "Enter password: " password

log_timestamp() {
    echo "$(date +%s000) $1" >> "$cuts_log_path"
}

# Doing the recording inspired by
# https://betterprogramming.pub/how-to-record-flutter-integration-tests-with-github-actions-1ca670eff94a

# Start recording


rm "$cuts_log_path"
xcrun simctl io booted recordVideo "$full_video_path" -f &
log_timestamp "recording_start"
sleep 5
export RECORDING_PID=${!}
echo "Recording process up with pid: ${RECORDING_PID}"
echo "Running app"
flutter drive \
--driver=generate_screenshots/test_driver.dart \
--target=generate_screenshots/app_test.dart \
--dart-define=TEST_USER="$username" \
--dart-define=TEST_PASSWORD="$password" > "$test_log_path"

# Write cut timestamps from test.log to cut.log

echo "Finishing recording"
timestamp_prefix="flutter: TIMESTAMP: "
extracted_timestamps=$(\
awk -v s="$timestamp_prefix" 'index($0, s) == 1' "$test_log_path" | \
sed -e "s/^$timestamp_prefix//"\
)
echo "$extracted_timestamps"  >> "$cuts_log_path"
rm "$test_log_path"

# End recording

log_timestamp "recording_end"
sleep 5
kill -SIGINT $RECORDING_PID
sleep 10
echo ""

# Cut smaller screencasts

echo "Cutting smaller screencasts"
timestamps=()
descriptions=()
while read cut_info; do
  cut_info_array=($cut_info)
  timestamp=${cut_info_array[0]}
  description=${cut_info_array[1]}
  timestamps+=("$timestamp")
  descriptions+=("$description")
done < "$cuts_log_path"

get_seconds_since_start() {
    echo $((($1-${timestamps[0]})/1000))
}

# Format seconds as hh:mm:ss, see https://stackoverflow.com/a/13425821
format_seconds_as_time() {
    ((
        sec=$1%60,
        $1/=60,
        min=$1%60,
        hrs=$1/60
    ))
    echo $(printf "%02d:%02d:%02d" $hrs $min $sec)
}

for ((i=2; i<${#timestamps[@]}-1; i++))
do
    description=${descriptions[i]}
    echo "Cutting $description"
    start_seconds=$(get_seconds_since_start ${timestamps[i-1]})
    end_seconds=$(get_seconds_since_start ${timestamps[i]})
    start_time=$(format_seconds_as_time start_seconds)
    end_time=$(format_seconds_as_time end_seconds)
    ## Use ffmpeg to cut, see https://stackoverflow.com/a/42827058
    video_path="${output_directory}${description}.mov"
    ffmpeg -y -loglevel error \
        -ss "$start_time" \
        -to "$end_time" \
        -i "$full_video_path" \
        -c copy "$video_path"
done
