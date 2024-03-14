#!/bin/bash

output_directory="../docs/screencasts/"
cuts_log_path="${output_directory}cuts.log"
test_log_path="${output_directory}test.log"
full_video_path="${output_directory}full.mov"

ffmpeg_log_level="warning"

# Time margin to be added, if needed
end_offset=0
start_offset=0

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
    --driver=generate_screendocs/test_driver.dart \
    --target=generate_screendocs/screencast_sequence.dart \
    --dart-define=TEST_USER="$username" \
    --dart-define=TEST_PASSWORD="$password" | tee "$test_log_path"

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

cut_video() {
    description=$1
    start_seconds=$2
    end_seconds=$3
    ((start_seconds-=$start_offset))
    ((end_seconds+=$end_offset))
    if [ $start_seconds -eq $end_seconds ]; then
        ((end_seconds+=1))
    fi
    total_seconds=$(($end_seconds-$start_seconds))
    start_time=$(format_seconds_as_time start_seconds)
    end_time=$(format_seconds_as_time end_seconds)
    total_time=$(format_seconds_as_time total_seconds)
    echo "Cutting $description ($total_time, $start_time – $end_time)"
    video_path="${output_directory}${description}.mp4"
    ffmpeg -y -loglevel "$ffmpeg_log_level" -an \
        -i "$full_video_path" \
        -pix_fmt yuv420p -vcodec h264 -crf 21 \
        -ss "$start_time" \
        -to "$end_time" \
        -avoid_negative_ts make_zero -async 1 \
        "$video_path"

    # Starting at first keyframe does not work as intended,
    # but leaving this code here in case somebody will try to cut out the
    # black frames in the beginning
    # first_keyframe=$(
    #     ffprobe -loglevel "$ffmpeg_log_level" \
    #         -select_streams v \
    #         -show_entries packet=pts_time \
    #         -of csv=print_section=0 \
    #         "$video_path" \
    #         | awk -F',' '{print $1}' \
    #         | head -1
    # )
    # echo $first_keyframe
}

cut_video "full_clean" \
    $(get_seconds_since_start ${timestamps[1]}) \
    $(get_seconds_since_start ${timestamps[${#timestamps[@]}-2]})

for ((i=2; i<${#timestamps[@]}-1; i++))
do
    description=${descriptions[i]}
    start_seconds=$(get_seconds_since_start ${timestamps[i-1]})
    ((start_seconds-=$start_offset))
    end_seconds=$(get_seconds_since_start ${timestamps[i]})
    ((end_seconds+=$end_offset))
    cut_video $description $start_seconds $end_seconds
done
