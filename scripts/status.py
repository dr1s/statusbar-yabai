#!/usr/local/bin/python3

import subprocess
import os
import re


def cmd(cmd):
    env = os.environ.copy()
    proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env)
    return proc.stdout.decode("utf-8")


def get_network_services():
    network_services = dict()
    network_services_cmd = cmd(["networksetup", "-listnetworkserviceorder"]).split("\n")
    for l in network_services_cmd:
        if re.search("Hardware Port", l):
            sname = " ".join(l.split(" ")[2:-2]).replace(",", "")
            sdev = l.split(" ")[-1].replace(")", "")
            ifconfig = cmd(["ifconfig", sdev]).split("\n")
            active = False
            for i in ifconfig:
                if re.search("status: active", i):
                    active = True
            network_services[sname] = dict()
            network_services[sname]["dev"] = sdev
            network_services[sname]["active"] = active
            ip = cmd(["networksetup", "-getinfo", sname]).split("\n")
            network_services[sname]["ip"] = None
            for i in ip:
                if re.search("IP address: ", i):
                    network_services[sname]["ip"] = i.split(": ")[1]
            if sname == "Wi-Fi":
                network_services[sname]["ssid"] = (
                    cmd(["networksetup", "-getairportnetwork", sdev])
                    .split(": ")[1]
                    .replace("\n", "")
                )
    return network_services


def get_volume():
    level = cmd(["osascript", "-e", "output volume of (get volume settings)"]).replace(
        "\n", ""
    )
    return level


def main():
    battery = ["pmset", "-g", "batt"]
    bat_cmd = cmd(battery).split("\n")
    status_string = str()
    bat_charging = None
    if re.search("AC Power", bat_cmd[0]):
        bat_charging = "AC"

    bat_perc = bat_cmd[1].split("\t")[1].split("%")[0]
    status_string += "%s@%s@" % (bat_perc, bat_charging)

    ns = get_network_services()
    for n in ns:
        if ns[n]["active"]:
            if not n == "Wi-Fi":
                status_string += "%s@@%s" % (n, ns[n]["ip"])
            else:

                status_string += "Wi-Fi@%s@@" % (ns[n]["ssid"])

    status_string += get_volume()
    print(status_string)


if __name__ == "__main__":
    main()
