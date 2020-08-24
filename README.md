# Crypto2099 Simple Live View

This simple script was created to give most of the "benefits" of the `cardano-node` LiveView mode without the operational overhead and security risks. 

Using this relatively simple script you can fetch the most pertinent information about your `cardano-node` instance while running in "SimpleView" as a service for maximum system reliability.

This script uses the Prometheus stats baked into `cardano-node` so you may need to change the `promport` variable to match the Prometheus port (set to 12798 by default) specified in your `mainnet-config.json` file. You can also adjust the `refreshrate` variable to increase or decrease the refresh rate of the script (set to refresh every two (2) seconds by default).

#### Version 1.4 Changes

Version 1.4 introduces a couple of changes including the ability to provide a "Node Name" to label your stats view (i.e. "[TICKR] Relay #1").

Also introduced a check for the total number of remote peers connected. This is configured via the `cardanoport` variable and may need to be updated if you do not use the default `3001` port.

## Installation

```
cd ~
git clone https://github.com/crypto2099/simpleLiveView
cd simpleLiveView
./liveview.sh
```

### Attribution
Author: Adam Dean (Twitter: @adamkdean)

Created By: Crypto2099, Corp

Twitter: https://twitter.com/Crypto2099Corp

Homepage: https://crypto2099.io

Cardano Stake Pools: BUFFY | SPIKE
