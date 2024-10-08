#!/bin/bash

output_directory="../docs/screencasts/"
assets_directory="assets/images/tutorial/"
cuts_log_path="${output_directory}cuts.log"
flutter_log_path="${output_directory}flutter.log"
full_video_path="${output_directory}full.mov"

timestamp_prefix="TIMESTAMP: "

ffmpeg_log_level="warning"

# The following flags are for testing single steps and should be set to true
redo_recording=true
redo_cutting=true
redo_gif_creation=true
redo_gif_copying=true

log_timestamp() {
    echo "$(date +%s000) $1" >> "$cuts_log_path"
}

if $redo_recording; then

    read -p "Enter username: " username
    read -p "Enter password: " password

    # Doing the recording was inspired by
    # https://betterprogramming.pub/how-to-record-flutter-integration-tests-with-github-actions-1ca670eff94a

    # Start recording

    rm -f "$cuts_log_path"
    rm -f "$flutter_log_path"
    xcrun simctl io booted recordVideo "$full_video_path" -f &
    log_timestamp "recording_start"
    sleep 5
    export RECORDING_PID=${!}
    echo "Recording process up with pid: ${RECORDING_PID}"
    echo "Running app"
    flutter drive \
        --driver=generate_screendocs/test_driver.dart \
        --target=generate_screendocs/screencast_sequence.dart \
        --dart-define=TIMESTAMP_PREFIX="$timestamp_prefix" \
        --dart-define=TEST_USER="$username" \
        --dart-define=TEST_PASSWORD="$password" | tee "$flutter_log_path"

    # Write cut timestamps from test.log to cut.log

    echo "Finishing recording"

    logged_timestamp_prefix="flutter: $timestamp_prefix"
    extracted_timestamps=$(\
        awk -v s="$logged_timestamp_prefix" 'index($0, s) == 1' "$flutter_log_path" | \
        sed -e "s/^$logged_timestamp_prefix//"\
    )
    echo "$extracted_timestamps"  >> "$cuts_log_path"

    # End recording

    log_timestamp "recording_end"
    sleep 5
    kill -SIGINT $RECORDING_PID
    sleep 10
    echo ""

fi

if $redo_cutting; then

    # Cut smaller screencasts

    echo "Cutting smaller screencasts at keyframes closest before logged times"

    timestamps=()
    descriptions=()
    while read cut_info; do
        if [ -z "$cut_info" ]; then
            continue
        fi
        cut_info_array=($cut_info)
        timestamp=${cut_info_array[0]}
        description=${cut_info_array[1]}
        timestamps+=("$timestamp")
        descriptions+=("$description")
    done < "$cuts_log_path"

    get_frame_starts() {
        local video_path=$1
        echo $(
            ffprobe -loglevel "$ffmpeg_log_level" \
                -select_streams v \
                -show_entries frame=pts_time \
                -of csv=print_section=0 \
                "$video_path" \
                | awk -F',' '{print $1}'
        )
    }

    get_frame_durations() {
        local video_path=$1
        echo $(
            ffprobe -loglevel "$ffmpeg_log_level" \
                -select_streams v \
                -show_entries frame=duration_time \
                -of csv=print_section=0 \
                "$video_path" \
                | awk -F',' '{print $1}'
        )
    }

    frame_starts=($(get_frame_starts $full_video_path))
    frame_durations=($(get_frame_durations $full_video_path))

    get_difference() {
        local first_float=$1
        local second_float=$2
        local difference=$(echo "$first_float - $second_float" | bc)
        echo ${difference#-}
    }

    get_closest_previous_frame_start() {
        local target=$1
        local best_fit_index=0
        local smallest_difference=$(get_difference $target ${frame_starts[0]})
        for ((j=1; j<${#frame_starts[@]}; j++)); do
            local current_value=${frame_starts[j]}
            local current_difference=$(get_difference $target $current_value)
            if (( $(echo "$current_value > $target" | bc) )); then
                break
            fi
            if (( $(echo "$current_difference < $smallest_difference" | bc) )); then
                smallest_difference=$current_difference
                best_fit_index=$j
            fi
        done
        echo "${frame_starts[best_fit_index]}"
    }

    get_frame_end() {
        local index=$1
        local frame_start=${frame_starts[index]}
        local frame_duration=${frame_durations[index]}
        echo $(echo "$frame_start + $frame_duration" | bc)
    }

    get_closest_previous_frame_end() {
        local target=$1
        local best_fit_index=0
        local smallest_difference=$(get_difference $target $(get_frame_end 0))
        for ((j=1; j<${#frame_starts[@]}; j++)); do
            local current_value=$(get_frame_end $j)
            local current_difference=$(get_difference $target $current_value)
            if (( $(echo "$current_value > $target" | bc) )); then
                break
            fi
            if (( $(echo "$current_difference < $smallest_difference" | bc) )); then
                smallest_difference=$current_difference
                best_fit_index=$j
            fi
        done
        echo "$(get_frame_end $best_fit_index)"
    }

    get_seconds_since_start() {
        echo $(printf %.3f "$(($1-${timestamps[0]}))e-3")
    }

    cut_video() {
        local description=$1
        local start_seconds=$(get_closest_previous_frame_start $2)
        local end_seconds=$(get_closest_previous_frame_end $3)

        echo "Cutting $description $start_seconds – $end_seconds (originally $2 – $3)"

        local video_path="${output_directory}${description}.mp4"

        ffmpeg -y -loglevel "$ffmpeg_log_level" -an \
            -i "$full_video_path" \
            -ss "$start_seconds" \
            -to "$end_seconds" \
            -pix_fmt yuv420p \
            "$video_path"
    }

    cut_video "full_clean" \
        $(get_seconds_since_start ${timestamps[1]}) \
        $(get_seconds_since_start ${timestamps[${#timestamps[@]}-2]})

    # Skip first and last entries (recording_start and recording_end)
    for ((i=2; i<${#timestamps[@]}-1; i+=2)); do
        description=${descriptions[i]}
        start_seconds=$(get_seconds_since_start ${timestamps[i-1]})
        end_seconds=$(get_seconds_since_start ${timestamps[i]})
        cut_video $description $start_seconds $end_seconds
    done

fi

if $redo_gif_creation; then

    for video_path in `find $output_directory -name "*.mp4" -type f`; do
        video_name=$(basename $video_path)
        if [[ "$video_name" == full*.mp4 ]]; then continue; fi
        gif_name="${video_name%.mp4}.gif"
        gif_path="${output_directory}$gif_name"
        echo "Creating $gif_path"
        # From https://superuser.com/a/556031
        ffmpeg -y -loglevel "$ffmpeg_log_level" \
            -i "$video_path" \
            -vf "fps=10,scale=320:-1:flags=lanczos" -c:v pam -f image2pipe - | \
            magick -delay 10 - -loop 0 -layers optimize "$gif_path"
    done

fi

if $redo_gif_copying; then

    for gif_path in `find $output_directory -name "*_loopable.gif" -type f`; do
        gif_name="$(basename $gif_path)"
        assets_path="${assets_directory}$gif_name"
        echo "Copying $gif_name to $assets_directory"
        cp $gif_path $assets_path
    done

fi
