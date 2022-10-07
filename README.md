# eyesy-piboy

The operating system for the EYESY video synthesizer device - remixed. Then re-remixed for use on
- PiBoy DMG
  - Tested on Raspberry Pi 4 B with the official [PiBoy DMG Image](https://experimentalpi.com/downloads.html).

Adaptation of the Critter&Guitari Eyesy video synth in order to run it on a regular Raspberry Pi
Eyesy Manual : https://www.critterandguitari.com/manual?m=EYESY_Manual#eyesy%E2%84%A2-user-manual

### Notable changes
- [add command-line argument support for sound device, rate, and period](https://github.com/rasprague/eyesey-piboy/commit/a640d715b3b469e6a3f973992e64beeec6938cbf)
- [add start_python_foreground.sh to start python video in foreground](https://github.com/rasprague/eyesey-piboy/commit/7edb6ddf3b73518912475c6f1862e6e80f524363)
- [add list-pcms.py utility to list available sound cards](https://github.com/rasprague/eyesey-piboy/commit/98bd0b147c0dbe6e897164b15b3fb9db83462efd)
- [add /quit OSC message, create controller-osc.py to translate gamepad controller presses to OSC messages](https://github.com/rasprague/eyesey-piboy/commit/4f8dc3119ef0065946df1a9d0a6ccee58265c5e5)

# Thanks to
- [okyeron](https://github.com/okyeron) for doing the hard work of [porting Eyesy to Regular Raspberry Pi](https://github.com/okyeron/EYESY_OS_for_RasPi)
- [Critter & Guitari](https://www.critterandguitari.com/) for the amazing work with the [Eyesy Video Synthesizer](https://www.critterandguitari.com/eyesy) (suport Critter & Guitari, go buy their products!)

# Requirements
# Requirements
- A working Raspberry Pi / Retropie setup on one of the following handheld hardware:
  - PiBoy DMG, see [the PiBoy DMG Getting Started guide](https://resources.experimentalpi.com/the-complete-piboy-dmg-getting-started-guide/)

### Installation :

The instructions assume that you already have a working Retropie installation with an internet connection.

**Open Terminal or SSH into you Pi and run the following commands:**

### Download source code, build
```
git clone https://github.com/rasprague/eyesey-piboy.git Eyesy
cd Eyesy
./deploy.sh
 ```

### Make scripts user executable
```
chmod u+x *.sh *.py
```

FINISHME

### Usage:
 - Connect a display to the first hdmi out
 - Boot up your RasPi
 - (Via SSH) Run the `~/Eyesy/start_web.sh` script to start the web services. Then you can start/stop the video engine from the web editor - see below.

   In order to control Eyesy you
   will have to use the TouchOSC Android (or iOS) app (see below) or a MIDI controller.
   
   You will also need a sound card. Sound card setup is beyond the scope of this readme and will depend on your specific device.
   
   Note - EYESY is looking for your sound card to be the "default" device.
   
### Control:

**Control via TouchOSC:**
- Download and install the TouchOSC app for your iOS or Android device (it is not free, I've been looking for free/open-source alternatives, please let me know if you know one; nevertheless, this app is well developed and it's also nice to suppot this kind of effort I believe)
- Download the fitting TouchOSC template from [here](https://www.dropbox.com/sh/l5bhlr3li820olc/AAD399Ej1-16u7qgEB3BTCQ1a?dl=0) to your device and import it via the app (in Layout).
- In the OSC setting of the app set Host to the ip adress of your pi (your device and your pi must be on the same network)
- Set the outgoing port to `4000` and ingoing to `4001`
- You're `Done`!
 
 
**Control via midi in messages (should be plug and play):**
  | Midi CC    | 21,22,23,24 | 25               | 26               | 27               | 28                | 29                | 30              | 31        | 32           | 33              | 34                         | 35       |
  |-------|-------------|------------------|----------------------|-------------------|---------------------|-----------|--------------|-----------------|----------------------------|----------|------------|----------------|
  | Control | Mode Params | Background Color | Scene selection | Save or delete (long hold) | Auto Clear Toggle | Mode Selection | Take Screenshot | Info Disp | Send Trigger | ShiftKey | Input Gain | Trigger Source |


### Web Editor
The web editor lets you edit the pygame scripts that generate the visuals on the fly. It should be accessible at http://raspberrypi.local:8080/ (or IP:8080 where IP is the current ip adress of your Pi)

See the Eyesy manual for more details on using the web editor.

### Uninstall:
Simply run: `./uninstall.sh`

### Rem:

- You can use the stereo input in your Modes, in Python there are accessible via `etc.audio_left` and `etc.audio_right` in the scripts, `etc.audio_in` remains L+R



--
# orignal m8c README below
# EYESY_OS_RasPi

The operating system for the EYESY video synthesizer device - remixed.

Adaptation of the Critter&Guitari Eyesy video synth in order to run it on a regular Raspberry Pi
Eyesy Manual : https://www.critterandguitari.com/manual?m=EYESY_Manual#eyesy%E2%84%A2-user-manual



### Installation :

```
git clone https://github.com/okyeron/EYESY_OS_for_RasPi.git Eyesy
cd Eyesy
./deploy.sh
 ```
  
### Usage:
 - Connect a display to the first hdmi out
 - Boot up your RasPi
 - (Via SSH) Run the `~/Eyesy/start_web.sh` script to start the web services. Then you can start/stop the video engine from the web editor - see below.

   In order to control Eyesy you
   will have to use the TouchOSC Android (or iOS) app (see below) or a MIDI controller.
   
   You will also need a sound card. Sound card setup is beyond the scope of this readme and will depend on your specific device.
   
   Note - EYESY is looking for your sound card to be the "default" device.
   
### Control:

**Control via TouchOSC:**
- Download and install the TouchOSC app for your iOS or Android device (it is not free, I've been looking for free/open-source alternatives, please let me know if you know one; nevertheless, this app is well developed and it's also nice to suppot this kind of effort I believe)
- Download the fitting TouchOSC template from [here](https://www.dropbox.com/sh/l5bhlr3li820olc/AAD399Ej1-16u7qgEB3BTCQ1a?dl=0) to your device and import it via the app (in Layout).
- In the OSC setting of the app set Host to the ip adress of your pi (your device and your pi must be on the same network)
- Set the outgoing port to `4000` and ingoing to `4001`
- You're `Done`!
 
 
**Control via midi in messages (should be plug and play):**
  | Midi CC    | 21,22,23,24 | 25               | 26               | 27               | 28                | 29                | 30              | 31        | 32           | 33              | 34                         | 35       |
  |-------|-------------|------------------|----------------------|-------------------|---------------------|-----------|--------------|-----------------|----------------------------|----------|------------|----------------|
  | Control | Mode Params | Background Color | Scene selection | Save or delete (long hold) | Auto Clear Toggle | Mode Selection | Take Screenshot | Info Disp | Send Trigger | ShiftKey | Input Gain | Trigger Source |


### Web Editor
The web editor lets you edit the pygame scripts that generate the visuals on the fly. It should be accessible at http://raspberrypi.local:8080/ (or IP:8080 where IP is the current ip adress of your Pi)

See the Eyesy manual for more details on using the web editor.

### Uninstall:
Simply run: `./uninstall.sh`

### Rem:

- You can use the stereo input in your Modes, in Python there are accessible via `etc.audio_left` and `etc.audio_right` in the scripts, `etc.audio_in` remains L+R

