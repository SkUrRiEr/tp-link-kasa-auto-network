# TP-Link IOT Device Capture

This is a bunch of scripts to automatically detect TP-Link "Kasa" IOT devices and connect them to a specified network.

See https://www.kasasmart.com/ for the line of devices.

## Requirements

1. A device with a WiFi card, e.g. a laptop, desktop or Raspberry Pi
2. To be running a Linux distribution on that device
3. Network Manager
4. PyHS100

### WiFi card requirements

* Must be capable of connecting to 2.4GHz 802.11 networks. Any modern "n" or newer device should work. Older "g" or "b" devices might not.

### Network Manager

https://wiki.gnome.org/Projects/NetworkManager

This will most likely be instlled by default if you're using a desktop Linux distribution, however you'll have to install it manually (and re-configure your WiFi connection) on a Raspberry Pi or other embedded system.

This uses the CLI tool to connect to the IOT device's setup network, so that tool must be available in your PATH.

To verify this, run:

```
nmcli device wifi list
```

and a list of WiFi networks should appear.

### PyHS100

https://github.com/GadgetReactor/pyHS100

This is a library and a simple CLI application to talk to TP-Link Kasa devices.

#### Installation:

(I am not a Python expert, so these steps may be overly verbose)

1. Install Python 3.4 or newer
2. Install pip
3. Clone the git repository
4. Run `pip install ./`

You should be able to now run commands like:

```
pyhs100 discover
```

without errors.


## Usage

**Warning: this will disconnect you from your WiFi network if it finds an IOT setup network.**

Simply run the command:

```
./set_network.sh SSID PASSWORD
```

and it will automatically find any unconfigured IOT devices, connect to their setup network and then configure them with the SSID and password supplied on the commandline.

It will exit after the first device is found.

I believe that the specific command used to do this assumes the network is WPA, so this might not do the correct thing for other types of network.

*Note:* Network Manager caches scan results, so running this multiple times in a row may cause it to instruct Network Manager to connect to a network that no-longer exists. This will cause lots of errors as the smart plug won't exist, but it will clean up the connection once it's finished failing. It _may_ re-configure an IOT device on your network if this happens.

## How does it work?

References:
* https://github.com/softScheck/tplink-smartplug
* https://www.softscheck.com/en/reverse-engineering-tp-link-hs110/
* https://github.com/softScheck/tplink-smartplug/blob/master/tplink-smarthome-commands.txt

Unconfigured IOT devices create a network named something like "TP-LINK_Smart Plug_AABB" where "AABB" is the last four digits of their MAC address.

Upon connecting to this network, you can send commands normally - there's no requirement on the plug's part to _actually_ be configured before it works.

One of the supported commands sets the network they should connect to on startup (and reboots the device).

So the script:
1. uses `nmcli` to search for these setup networks
2. configures a connection in Network Manager for the network found and connects to it (this means we don't actually care what the WiFi device name is)
3. uses `pyhs100` to detect the device and determine it's IP (`pyhs100` doesn't always work if it has to detect the device before issuing a command)
4. issues the command to set the connection details
5. cleans up the connection created in step 2

## Future Plans

* Implement proper error handling so that it detects and deals with cached networks
* Turn this into a service that could be run 24/7 on a Raspberry Pi
* See if this can be hooked into Network Manager's periodic scanning
