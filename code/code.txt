import tkinter as tk
from tkinter import ttk
import psutil
import math
import time

root = tk.Tk()
root.title("System Monitor")
root.geometry("800x600")
root.configure(bg="#1e1e2e")
root.resizable(True, True)

style = ttk.Style()
style.theme_use("clam")
style.configure("TFrame", background="#1e1e2e")
style.configure("TLabel", background="#1e1e2e", foreground="#cdd6f4", font=("Arial", 11))
style.configure("TProgressbar", troughcolor="#313244")

ttk.Label(root, text="System Monitor", font=("Arial", 24, "bold"), foreground="#89b4fa").pack(pady=15)

cards_frame = ttk.Frame(root)
cards_frame.pack(fill="x", padx=20, pady=10)

def create_card(parent, title, color):
    card = ttk.Frame(parent)
    card.pack(side="left", fill="both", expand=True, padx=5)
    ttk.Label(card, text=title, font=("Arial", 12, "bold"), foreground=color).pack(pady=5)
    value_label = ttk.Label(card, text="0%", font=("Arial", 28, "bold"), foreground=color)
    value_label.pack(pady=10)
    bar = ttk.Progressbar(card, length=150, mode="determinate")
    bar.pack(pady=5)
    detail_label = ttk.Label(card, text="", font=("Arial", 9), foreground="#6c7086")
    detail_label.pack(pady=5)
    return value_label, bar, detail_label

cpu_label, cpu_bar, cpu_detail = create_card(cards_frame, "CPU", "#f38ba8")
ram_label, ram_bar, ram_detail = create_card(cards_frame, "RAM", "#a6e3a1")
disk_label, disk_bar, disk_detail = create_card(cards_frame, "Disk C:", "#89b4fa")
net_label, net_bar, net_detail = create_card(cards_frame, "Network", "#fab387")

graphs_frame = ttk.Frame(root)
graphs_frame.pack(fill="both", expand=True, padx=20, pady=10)

cpu_graph_frame = ttk.Frame(graphs_frame)
cpu_graph_frame.pack(fill="both", expand=True)
ttk.Label(cpu_graph_frame, text="CPU History", foreground="#f38ba8", font=("Arial", 10, "bold")).pack(anchor="w")
cpu_canvas = tk.Canvas(cpu_graph_frame, bg="#313244", height=80, highlightthickness=0)
cpu_canvas.pack(fill="x", pady=5)

ram_graph_frame = ttk.Frame(graphs_frame)
ram_graph_frame.pack(fill="both", expand=True)
ttk.Label(ram_graph_frame, text="RAM History", foreground="#a6e3a1", font=("Arial", 10, "bold")).pack(anchor="w")
ram_canvas = tk.Canvas(ram_graph_frame, bg="#313244", height=80, highlightthickness=0)
ram_canvas.pack(fill="x", pady=5)

cpu_history = [0] * 100
ram_history = [0] * 100
old_net_sent = psutil.net_io_counters().bytes_sent if hasattr(psutil, 'net_io_counters') else 0
old_net_recv = psutil.net_io_counters().bytes_recv if hasattr(psutil, 'net_io_counters') else 0

def draw_graph(canvas, data, color):
    canvas.delete("all")
    w = canvas.winfo_width()
    h = canvas.winfo_height()
    if w < 10 or h < 10:
        return
    if len(data) < 2:
        return
    step = w / (len(data) - 1)
    points = []
    for i, val in enumerate(data):
        x = i * step
        y = h - (val / 100.0 * h)
        points.extend([x, y])
    if len(points) >= 4:
        for i in range(0, len(points) - 2, 2):
            canvas.create_line(points[i], points[i+1], points[i+2], points[i+3], fill=color, width=2)

def update():
    global old_net_sent, old_net_recv

    cpu = psutil.cpu_percent()
    cpu_label.config(text=f"{cpu}%")
    cpu_bar["value"] = cpu
    cpu_detail.config(text=f"Cores: {psutil.cpu_count()}")

    ram = psutil.virtual_memory()
    ram_label.config(text=f"{ram.percent}%")
    ram_bar["value"] = ram.percent
    ram_detail.config(text=f"Used: {ram.used // (1024**3)}GB / {ram.total // (1024**3)}GB")

    disk = psutil.disk_usage("C:")
    disk_label.config(text=f"{disk.percent}%")
    disk_bar["value"] = disk.percent
    disk_detail.config(text=f"Free: {disk.free // (1024**3)}GB / {disk.total // (1024**3)}GB")

    try:
        net = psutil.net_io_counters()
        sent_speed = (net.bytes_sent - old_net_sent) / 1024
        recv_speed = (net.bytes_recv - old_net_recv) / 1024
        old_net_sent = net.bytes_sent
        old_net_recv = net.bytes_recv
        net_label.config(text=f"{recv_speed:.0f} KB/s")
        net_bar["value"] = min(recv_speed / 1000 * 100, 100)
        net_detail.config(text=f"Up: {sent_speed:.0f} | Down: {recv_speed:.0f} KB/s")
    except:
        net_label.config(text="N/A")
        net_detail.config(text="No data")

    cpu_history.append(cpu)
    ram_history.append(ram.percent)
    if len(cpu_history) > 100:
        cpu_history.pop(0)
    if len(ram_history) > 100:
        ram_history.pop(0)

    draw_graph(cpu_canvas, cpu_history, "#f38ba8")
    draw_graph(ram_canvas, ram_history, "#a6e3a1")

    root.after(1000, update)

update()
root.mainloop()
