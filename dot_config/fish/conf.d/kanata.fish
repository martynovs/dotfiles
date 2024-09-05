status is-interactive && test (uname) = Darwin && type -q kanata || exit

alias kk kanata-restart

function kanata-list -d "List Kanata configs" -a filter
    for file in ~/.config/kanata/configs/*.kbd
        set -l config_name (basename $file .kbd)
        set -l plist_file ~/Library/LaunchAgents/com.kanata.$config_name.plist
        set -l service_label "com.kanata.$config_name"

        # Check if service is actually running (plist exists AND service is loaded)
        set -l is_running_status 0
        if test -f $plist_file; and launchctl list $service_label >/dev/null 2>&1
            set is_running_status 1
        end

        switch $filter
            case available
                if test $is_running_status -eq 0
                    echo $config_name
                end
            case running
                if test $is_running_status -eq 1
                    echo $config_name
                end
            case '*'
                # Default behavior: show all with status indicator
                if test $is_running_status -eq 1
                    echo "$config_name *"
                else
                    echo $config_name
                end
        end
    end
end

function kanata-start -d "Start Kanata with a specific config or all configs if none specified" -a config_name
    # Create launch agents directory if it doesn't exist
    mkdir -p ~/Library/LaunchAgents

    if test -z $config_name
        echo "No config specified, starting all configs..."
        set -l started_count 0
        set -l already_running_count 0

        for config_file in ~/.config/kanata/configs/*.kbd
            set -l config_name (basename $config_file .kbd)
            set -l plist_file ~/Library/LaunchAgents/com.kanata.$config_name.plist
            set -l service_label "com.kanata.$config_name"

            # Check if service is already running
            if test -f $plist_file; and launchctl list $service_label >/dev/null 2>&1
                echo "Kanata service for '$config_name' is already running"
                set already_running_count (math $already_running_count + 1)
            else
                echo "Starting Kanata service for: $config_name"

                # Check config file validity first
                if not kanata --check -c $config_file >/dev/null 2>&1
                    echo "Config validation failed for: $config_name"
                    echo "Run 'kanata --check -c $config_file' to see detailed errors"
                    continue
                end

                _kanata_create_service $config_name $config_file
                if launchctl load ~/Library/LaunchAgents/com.kanata.$config_name.plist 2>/dev/null
                    set started_count (math $started_count + 1)
                else
                    echo "Failed to start service for: $config_name"
                end
            end
        end

        if test $started_count -gt 0
            sleep 2
            echo "Started $started_count new Kanata service(s)"
        end
        if test $already_running_count -gt 0
            echo "$already_running_count Kanata service(s) were already running"
        end
        echo "Use 'kanata-stop' to stop all services"
        return
    end

    set -l config_file ~/.config/kanata/configs/$config_name.kbd
    if not test -f $config_file
        echo "Config file not found: $config_file"
        echo "Available configs:"
        kanata-list
        return 1
    end

    set -l plist_file ~/Library/LaunchAgents/com.kanata.$config_name.plist
    set -l service_label "com.kanata.$config_name"

    # Check if service is already running
    if test -f $plist_file; and launchctl list $service_label >/dev/null 2>&1
        echo "Kanata service for '$config_name' is already running"
        echo "Use 'kanata-stop $config_name' to stop it first if you want to restart"
        return 0
    end

    echo "Starting Kanata service for: $config_name"

    # Check config file validity first
    if not kanata --check -c $config_file >/dev/null 2>&1
        echo "Config validation failed for: $config_name"
        echo "Run 'kanata --check -c $config_file' to see detailed errors"
        return 1
    end

    _kanata_create_service $config_name $config_file
    if launchctl load ~/Library/LaunchAgents/com.kanata.$config_name.plist 2>/dev/null
        sleep 2
    else
        echo "Failed to start Kanata service for '$config_name'"
        return 1
    end
end

function _kanata_create_service -d "Create launchd plist for kanata config" -a config_name config_file
    set -l plist_file ~/Library/LaunchAgents/com.kanata.$config_name.plist
    set -l log_dir ~/Library/Logs/kanata
    set -l kanata_bin (which kanata)
    mkdir -p $log_dir

    # Create the launchd plist file
    printf '<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata.%s</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/bin/sudo</string>
        <string>-A</string>
        <string>%s</string>
        <string>-c</string>
        <string>%s</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>SUDO_ASKPASS</key>
        <string>%s</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>%s/%s.log</string>
    <key>StandardErrorPath</key>
    <string>%s/%s.log</string>
    <key>WorkingDirectory</key>
    <string>%s</string>
</dict>
</plist>' $config_name $kanata_bin $config_file (command -v askpass) $log_dir $config_name $log_dir $config_name $HOME >$plist_file
end

function kanata-stop -d "Stop running Kanata services (all or specific config)" -a config_name
    if test -z $config_name
        echo "Stopping all Kanata services..."
        for plist_file in ~/Library/LaunchAgents/com.kanata.*.plist
            set -l service_name (basename $plist_file .plist)
            set -l config_name (string replace "com.kanata." "" $service_name)
            echo "Stopping service for: $config_name"
            launchctl unload $plist_file 2>/dev/null
            rm -f $plist_file
        end
        echo "All Kanata services stopped"
    else
        # Stop specific config service
        set -l plist_file ~/Library/LaunchAgents/com.kanata.$config_name.plist
        if test -f $plist_file
            echo "Stopping Kanata service for config '$config_name'"
            launchctl unload $plist_file 2>/dev/null
            rm -f $plist_file
            echo "Kanata service for '$config_name' stopped successfully"
        else
            echo "No Kanata service found for config: $config_name"
        end
    end
end

function kanata-restart -d "Restart running Kanata services"
    echo "Restarting running Kanata services..."
    set -l running_configs (kanata-list running)

    if test (count $running_configs) -eq 0
        echo "No Kanata services are currently running"
        echo "Use 'kanata-start' to start services"
        return 0
    end

    echo "Currently running configs: "(string join ", " $running_configs)

    # Stop all services
    kanata-stop
    # Wait a moment for services to fully stop
    sleep 1

    # Start each previously running config
    for config in $running_configs
        echo "Restarting: $config"
        kanata-start $config
    end
    echo "All previously running Kanata services have been restarted"
end

function kanata-logs -d "View Kanata service logs" -a config_name
    set -l log_dir ~/Library/Logs/kanata

    if test -z $config_name
        echo "Available log files:"
        for log_file in $log_dir/*.log
            if test -f $log_file
                set -l name (basename $log_file .log)
                set -l size (du -h $log_file | cut -f1)
                set -l mtime (stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" $log_file)
                echo "  $name ($size, modified: $mtime)"
            end
        end
        echo ""
        echo "Usage: kanata-logs <config_name> [lines]"
        echo "Example: kanata-logs mx_keys 50"
        return
    end

    set -l log_file $log_dir/$config_name.log
    if not test -f $log_file
        echo "Log file not found: $log_file"
        return 1
    end

    set -l lines $argv[2]
    if test -z $lines
        set lines 50
    end

    echo "=== Last $lines lines of kanata service log for '$config_name' ==="
    tail -n $lines $log_file
end

# Completions for kanata functions
complete -c kanata-list -f -a "available running" -d "Filter type"
complete -c kanata-start -f -a "(kanata-list available)" -d "Available Kanata config (not running)"
complete -c kanata-stop -f -a "(kanata-list running)" -d "Running Kanata config"
complete -c kanata-logs -f -a "(for file in ~/Library/Logs/kanata/*.log; test -f \$file; and basename \$file .log; end)" -d "Available log files"
