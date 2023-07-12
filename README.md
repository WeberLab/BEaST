# BEaST

## Installation on Ubuntu: [note: a lot of the following was borrowed from: https://rpubs.com/conge/beast_intro]

### 0. You might need these installed:

Dependencies

```
sudo apt install cmake-curses-gui
```

### 1. First install MINC

```
cd ~/Downloads
wget http://packages.bic.mni.mcgill.ca/minc-toolkit/Debian/minc-toolkit-1.9.18-20200813-Ubuntu_20.04-x86_64.deb
sudo dpkg -i minc-toolkit-1.9.18-20200813-Ubuntu_20.04-x86_64.deb
source /opt/minc/1.9.18/minc-toolkit-config.sh
export LIBMINC_DIR=/opt/minc/1.9.18/lib/cmake/
```

[note: please add source /opt/minc/1.9.18/minc-toolkit-config.sh into your bashrc file so you don't have to do it every time before running the toolkit:]

```
echo "source /opt/minc/minc-toolkit-config.sh" >> ~/.bashrc;
```

[NOTE: if the above doesn't work, try: https://github.com/BIC-MNI/minc-toolkit-v2 But be forewarned, that thing is HUGE]

### 2. Install NIfTI libraries

```
sudo apt-get install libnifti-dev
```

### 3. Install library for Hierarchical Data Format 5 support

```
sudo apt-get install libhdf5-dev
```

## BEaST Proper

### 4. Download source code:

```
cd ~/Downloads
gh repo clone BIC-MNI/BEaST #note: this uses the git hub cli client; see [[[git]]]
cd BEaST
```

### 5. Compile and Install BEaST

Run the code below to configure the installation.

```
ccmake CMakeLists.txt
```

At this step, you need to make sure all the path is correct in the CMakeList.txt. Type “c” to configure the installation and type “g” to generate configuration. If everything is correct, runt the code below to install BEaST to your system.

For me, I needed to edit and include: /opt/minc/1.9.18/lib/cmake/ , as well as edit the NIFTI_ROOT to just be /usr

More Troubleshooting:
- NIFTI_ROOT should be set to /usr if you installed NIfTI libraries using the package libnifti-dev
- If the compiler cannot find hdf5.h you probably need to install libhdf5-serial-dev
- If you get the message: "Could not find module FindLIBMINC.cmake or a configuration file for package LIBMINC.", you must point to the directory containing either FindLIBMINC.cmake or LIBMINCConfig.cmake. If you have installed MINC Tool Kit, http://www.bic.mni.mcgill.ca/ServicesSoftware/ServicesSoftwareMincToolKit, the directory is most likely /opt/minc/lib
- make sure fsl's path isn't before your major ones: put this at the very end of your ~/.bashrc file: export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$PATH

Then:

```
make
sudo make install
```

### 6. Install BEaST Libraries

```
cd ~/Downloads
wget http://packages.bic.mni.mcgill.ca/tgz/beast-library-1.1.tar.gz
tar xzf beast-library-1.1.tar.gz
sudo mv beast-library-1.1 /opt/minc/1.9.18share/
```

## Running the Script

```
./location/of/script/BEaSTSkullStrip.sh /location/of/T1w.nii.gz [optional: /output/dir/and/prefix/name]
```
