# Incident Report: USB Mouse Enumeration Failure (Error -71)
**Date:** 2026-03-31
**System:** Artix Linux (OpenRC) | Ryzen 5 5600GT
**Status:** Resolved

## 1. The Story (Narrative)
I was working on my local environment when my generic "G5" mouse suddenly stopped responding. My first instinct was a physical port failure, as I had encountered this before and a simple "port swap" fixed it. This time, however, all USB ports seemed to be failing.

In a moment of "brain fog," I attempted to check the device status using `pavucontrol &`. I quickly realized this was a **conceptual error**: `pavucontrol` manages the PulseAudio/PipeWire sound server, not HID (Human Interface Device) hardware. 

I decided to go deeper into the Linux kernel layer, inspecting `/dev/input` and the kernel ring buffer to "gauge" what was happening at the hardware level.

## 2. Technical Diagnosis
Using `doas dmesg | tail`, I identified the following critical errors:
- `usb 3-1: device descriptor read/64, error -71`
- `usb 3-1: device not accepting address, error -71`
- `usb usb3-port1: unable to enumerate USB device`

### What is Error -71?
It is a **Protocol Error**. The kernel was attempting a "handshake" (enumeration) with the mouse, but the timing or the data packets were being corrupted or ignored. While this often points to hardware failure (cable strain), it can also be caused by a driver state mismatch.

## 3. The Solution
The fix was surprisingly software-based, which suggests a module loading timing issue on my Artix/OpenRC setup.

### Temporary Fix
I manually loaded the HID driver and "replugged" the device:
```bash
doas modprobe usbhid
```
# Unplugged and replugged the mouse
Immediately, `dmesg` confirmed success:
```bash
usb 3-1: New USB device found, idVendor=30fa, idProduct=0400
input: USB OPTICAL MOUSE as /devices/.../input16
```

# Permanent Implementation 
- To prevent this from recurring after a reboot, I added `usbhid`` to the *kernel modules load list:*

```bash
echo "usbhid" | doas tee /etc/modules-load.d/usbhid.con
```
