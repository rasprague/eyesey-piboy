# EYESY_OS_RasPi

The operating system for the EYESY video synthesizer device - remixed.

Adaptation of the Critter&Guitari Eyesy video synth in order to run it on a regular Raspberry Pi
Eyesy Manual : https://www.critterandguitari.com/manual?m=EYESY_Manual#eyesy%E2%84%A2-user-manual



### Installation :

 git clone https://github.com/okyeron/Eyesy_for_RasPi Eyesy
 cd Eyesy
 ./deploy.sh
 ```
  
### Usage:
 - Connect a display to the first hdmi out
 - Boot up your Raspi

   In order to control Eyesy you
   will have to use the TouchOSC Android (or iOS) app (see below).
   
### Control:


**Control via TouchOSC:**
- Download and install the TouchOSC app for your iOS or Android device (it is not free, I've been looking for free/opensource alternatives, please let me know if you know one; nevertheless, this app is well developped and it's also nice to suppot this kind of effort I believe)
- Download the fitting TouchOSC template from [here](https://www.dropbox.com/sh/l5bhlr3li820olc/AAD399Ej1-16u7qgEB3BTCQ1a?dl=0) to your device and import it via the app (in Layout).
- In the OSC setting of the app set Host to the ip adress of your pi (your device and your pi must be on the same network)
- Set the outgoing port to `4000` and ingoing to `4001`
- You're `Done`!
 
 
**Control via midi in messages (should be plug and play):**
  | Midi CC    | 21,22,23,24 | 25               | 26               | 27               | 28                | 29                | 30              | 31        | 32           | 33              | 34                         | 35       |
  |-------|-------------|------------------|----------------------|-------------------|---------------------|-----------|--------------|-----------------|----------------------------|----------|------------|----------------|
  | Control | Mode Params | Background Color | Scene selection | Save or delete (long hold) | Auto Clear Toggle | Mode Selection | Take Screenshot | Info Disp | Send Trigger | ShiftKey | Input Gain | Trigger Source |


### Web editor
The web editor lets you edit the pygame scripts that generate the visuals on the fly. It should be accessible at http://raspberrypi.local:8080/ (or IP:8080 where IP is the current ip adress of your Pi)

See the Eyesy manual for more details on using the web editor.

### Uninstall:
Simply run: `./uninstall.sh`

### Rem:

- If you have some letters flickering around on the screens and it disturbs you, you can edit `boot/cmdline.txt` by changing `fbcon=map:1` to `fbcon=map:2`. Note that this will deactivate the RaspberryPi boot and login text and you will therefore no longer be able to use it via a directly connnected screen and keyboard (only ssh will work).
- You can use the stereo input in your Modes, there are accessible via `etc.audio_left` and `etc.audio_right` in the scripts, `etc.audio_in` remains L+R

