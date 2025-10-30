#!/usr/bin/env fish
# echo "Waiting 60 seconds before applying config..."
# sleep 1
# echo "executing..."
# while true
#     echo "Attempting to apply config..."
#     timeout 30 talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.1 --file=./clusterconfig/main-srv-01.home.arpa.yaml --insecure
    
#     if test $status -eq 0
#         echo "Config applied successfully! Waiting 60 seconds before bootstrap..."
#         sleep 60
#         echo "Running bootstrap..."
#         talosctl bootstrap
#         break
#     else
#         echo "Config apply failed or timed out. Retrying in 60 seconds..."
#         sleep 60
#     end
# end

# echo "Bootstrap complete!"

echo "Waiting 60 seconds before applying config..."
sleep 60
echo "executing..."
while true
    echo "Attempting to apply config..."
    timeout 30 talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.6 --file=./clusterconfig/main-srv-06.home.arpa.yaml --insecure;
    
    if test $status -eq 0
        echo "Config applied successfully! Waiting 60 seconds before bootstrap..."
        break
    else
        echo "Config apply failed or timed out. Retrying in 60 seconds..."
        sleep 30
    end
end

echo "Bootstrap complete!"