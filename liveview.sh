#!/bin/bash

##
# Author: Adam Dean
# Created By: Crypto2099, Corp
# Twitter: https://twitter.com/Crypto2099Corp
# Homepage: https://crypto2099.io
# Cardano Stake Pools: BUFFY | SPIKE
##

promport=12798 # You may need to change this to match your configuration
refreshrate=2 # How often (in seconds) to refresh the view
cardanoport=3001 # You may need to change this to match your configuration
nodename="" # You can add your node's name here, 30 character limit!!!

version=$("$(command -v cardano-node)" version)
node_version=$(grep -oP '(?<=cardano-node )[0-9\.]+' <<< "${version}")
node_rev=$(grep -oP '(?<=rev )[a-z0-9]+' <<< "${version}" | cut -c1-8)

node_version=$(printf "%14s" "$node_version")
node_rev=$(printf "%14s" "$node_rev")
name=$(printf "%*s\n" $((36)) "$nodename")

# Version check courtesy of Martin [ATADA] Cardano Node Operator Scripts (https://github.com/gitmachtl/scripts)
versionCheck() { printf '%s\n%s' "${1}" "${2}" | sort -C -V; } #$1=minimal_needed_version, $2=current_node_version

# Add some colors
REKT='\033[1;31m'
GOOD='\033[0;32m'
NC='\033[0m'
INFO='\033[1;34m'

while true
do
  data=$(curl localhost:$promport/metrics 2>/dev/null)
  remotepeers=$(netstat -an|awk "\$4 ~ /${cardanoport}/"|grep -c ESTABLISHED)

  uptimens=$(grep -oP '(?<=rts_gc_wall_ms )[0-9]+' <<< "${data}")
  transactions=$(grep -oP '(?<=cardano_node_metrics_txsProcessedNum_int )[0-9]+' <<< "${data}")
  isleader=$(grep -oP '(?<=cardano_node_metrics_Forge_node_is_leader_int )[0-9]+' <<< "${data}")
  abouttolead=$(grep -oP '(?<=cardano_node_metrics_Forge_forge_about_to_lead_int )[0-9]+' <<< "${data}")
  forged=$(grep -oP '(?<=cardano_node_metrics_Forge_forged_int )[0-9]+' <<< "${data}")

  versionCheck '1.25.0' $node_version

  if [[ $? -ne 0 ]]; then
    peers=$(grep -oP '(?<=cardano_node_BlockFetchDecision_peers_connectedPeers_int )[0-9]+' <<< "${data}")
    blocknum=$(grep -oP '(?<=cardano_node_ChainDB_metrics_blockNum_int )[0-9]+' <<< "${data}")
    epochnum=$(grep -oP '(?<=cardano_node_ChainDB_metrics_epoch_int )[0-9]+' <<< "${data}")
    slotnum=$(grep -oP '(?<=cardano_node_ChainDB_metrics_slotNum_int )[0-9]+' <<< "${data}")
    density=$(grep -oP '(?<=cardano_node_ChainDB_metrics_density_real )[0-9e\.\-]+' <<< "${data}")
    kesperiod=$(grep -oP '(?<=cardano_node_Forge_metrics_currentKESPeriod_int )[0-9]+' <<< "${data}")
    kesremain=$(grep -oP '(?<=cardano_node_Forge_metrics_remainingKESPeriods_int )[0-9]+' <<< "${data}")
  else
    peers=$(grep -oP '(?<=cardano_node_metrics_connectedPeers_int )[0-9]+' <<< "${data}")
    blocknum=$(grep -oP '(?<=cardano_node_metrics_blockNum_int )[0-9]+' <<< "${data}")
    epochnum=$(grep -oP '(?<=cardano_node_metrics_epoch_int )[0-9]+' <<< "${data}")
    slotnum=$(grep -oP '(?<=cardano_node_metrics_slotNum_int )[0-9]+' <<< "${data}")
    density=$(grep -oP '(?<=cardano_node_metrics_density_real )[0-9e\.\-]+' <<< "${data}")
    kesperiod=$(grep -oP '(?<=cardano_node_metrics_currentKESPeriod_int )[0-9]+' <<< "${data}")
    kesremain=$(grep -oP '(?<=cardano_node_metrics_remainingKESPeriods_int )[0-9]+' <<< "${data}")
  fi;


  if ((uptimens<=0)); then
    echo -e "${REKT}COULD NOT CONNECT TO A RUNNING INSTANCE! PLEASE CHECK THE PROMETHEUS PORT AND TRY AGAIN!${NC}"
    exit
  fi

#  remotepeers=$(printf "%14s" "$remotepeers")
  peers=$(printf "%14s" "$peers / $remotepeers")
  epoch=$(printf "%14s" "$epochnum / $blocknum")
  slot=$(printf "%14s" "$slotnum")
  txcount=$(printf "%14s" "$transactions")
  density_science=$(printf "%14s" "${density}")
  density_float=$(printf "%.4f" "${density}")
  density_percent=$(bc <<< "${density_float}*100")
  real_density=$(printf "%.3f" "${density_percent}")
  density=$(printf "%13s%%" "${real_density}")

  if [[ isleader -lt 0 ]]; then
    isleader=0
    forged=0
  fi

  uptimes=$(($uptimens / 1000))
  min=0
  hour=0
  day=0
  if(($uptimes > 59)); then
    ((sec=$uptimes%60))
    ((uptimes=$uptimes/60))
    if(($uptimes > 59)); then
      ((min=$uptimes%60))
      ((uptimes=$uptimes/60))
      if(($uptimes > 23)); then
        ((hour=$uptimes%24))
        ((day=$uptimes/24))
      else
        ((hour=$uptimes))
      fi
    else
      ((min=$uptimes))
    fi
  else
    ((sec=$uptimes))
  fi

  day=$(printf "%02d\n" "$day")
  hour=$(printf "%02d\n" "$hour")
  min=$(printf "%02d\n" "$min")
  sec=$(printf "%02d\n" "$sec")

  uptime=$(echo "$day":"$hour":"$min":"$sec")
  uptime=$(printf "%14s" "$uptime")

  clear
  echo -e '+--------------------------------------+'
  echo -e '|   Simple Node Stats by Crypto2099    |'
  echo -e '+---------------------+----------------+'
  if [[ ! -z "$nodename" ]]; then
    name=$(printf "%30s" "${nodename}")
    echo -e "| Name: ${INFO}${name}${NC} |"
    echo -e '+---------------------+----------------+'
  fi
  echo -e "| Version             | ${INFO}${node_version}${NC} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Revision            | ${INFO}${node_rev}${NC} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Peers (Out / In)    | ${peers} |"
  echo -e "+---------------------+----------------+"
  echo -e "| Epoch / Block       | ${epoch} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Slot                | ${slot} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Uptime (D:H:M:S)    | ${uptime} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Transactions        | ${txcount} |"
  echo -e '+---------------------+----------------+'
  echo -e "| Chain Density       | ${density} |"
  echo -e '+---------------------+----------------+'
  if [[ $abouttolead -gt 0 ]]; then
    kesperiod=$(printf "%14s" "$kesperiod")
    kesremain=$(printf "%14s" "$kesremain")
    isleader=$(printf "%14s" "$isleader")
    forged=$(printf "%14s" "$forged")
    echo -e "|  ${GOOD}RUNNING IN BLOCK PRODUCER MODE! :)${NC}  |"
    echo -e "+---------------------+----------------+"
    echo -e "| KES PERIOD          | ${kesperiod} |"
    echo -e "+---------------------+----------------+"
    echo -e "| KES REMAINING       | ${kesremain} |"
    echo -e "+---------------------+----------------+"
    echo -e "| SLOTS LED           | ${isleader} |"
    echo -e "+---------------------+----------------+"
    echo -e "| BLOCKS FORGED       | ${forged} |"
    echo -e "+---------------------+----------------+"
  else
    echo -e "|  ${REKT}NOT A BLOCK PRODUCER! RELAY ONLY!${NC}   |"
    echo -e '+--------------------------------------+'
  fi


  echo -e "\n${INFO}Press [CTRL+C] to stop...${NC}"
  sleep $refreshrate
done
