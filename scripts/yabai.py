#!/usr/local/bin/python3


import subprocess
import os
import json


class yabai:
    def __init__(self, executable):
        self.executable = executable

    def cmd(self, args=[]):
        env = os.environ.copy()
        cmd = [self.executable, "-m", "query"] + args
        proc = subprocess.run(
            cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=env
        )
        try:
            data = json.loads(proc.stdout.decode("utf-8"))
        except json.decoder.JSONDecodeError:
            data = None
        return data

    def process_data(self, keys, data):
        values = list()
        if data:
            for k in keys:
                if k:
                    if data[k]:
                        values.append(data[k])
        return values

    def get_space_values(self, keys=[]):
        space = self.cmd(["--spaces", "--space"])
        return self.process_data(keys, space)

    def get_window_values(self, keys=[]):
        window = self.cmd(["--windows", "--window"])
        return self.process_data(keys, window)

    def get_total_spaces(self):
        return len(self.cmd(["--spaces"]))


def main():
    y = yabai("/usr/local/bin/yabai")
    active_space, type = y.get_space_values(["index", "type"])
    spaces = list()
    i = 1
    total_spaces = y.get_total_spaces()
    while i <= total_spaces:
        space_str = "(%s" % i

        if i == active_space:
            space_str += ")"
        spaces.append(space_str)
        i += 1

    app_title = y.get_window_values(["app", "title"])
    if len(app_title) > 1:
        if app_title[0] == app_title[1]:
            app_title.pop()
    print("[%s]@%s@%s" % (type, " ".join(spaces), " ".join(app_title)))
    #print("@%s@%s" % (" ".join(spaces), " ".join(app_title)))


if __name__ == "__main__":
    main()
