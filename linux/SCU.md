# SCU installation instructions
This document describes the process for installing MBTA software on a System Control Unit (SCU) server.

## Required items and information
* SCU installation USB drive
* SCU-specific configuration values
    * Name
    * Subnet
    * Address
    * Gateway
    * Nameserver
* SCU activation password

## Steps
1. Insert the SCU installation USB drive into the machine.
1. Boot/reboot the machine, holding down the F2/Del key until you reach the BIOS screen:
    1. Change the first boot option to the USB device.
    1. Save changes and exit, which will cause the machine to reboot.
1. Wait until you reach the "GNU GRUB" menu:
    1. Select "Try or Install Ubuntu Server", or wait 30 seconds which will automatically select that option.
1. Wait until you reach the "Network connections" screen:
    1. Select the first ethernet device.
    1. Select "Edit IPv4".
    1. Change "IPv4 Method" to "Manual".
    1. Fill out the "Subnet", "Address", "Gateway", and "Nameserver" fields with the provided values for this SCU.
    1. Press "Save".
    1. Press "Done" to complete this screen.
1. On the "Profile setup" screen:
    1. Set "Your servers name" to the provided value for this SCU (use lowercase letters).
    1. Set "Choose a password" and "Confirm your password" to `ubuntu`.
    1. Press "Done" to complete this screen.
1. At the "Confirm destructive action" prompt, press "Continue".
1. Wait until the button at the bottom changes to "Reboot Now", but do NOT press it yet. This will take several minutes.
1. Press the F2 key to open a command prompt:
    1. Type `/cdrom/activate-scu` and press Enter.
    1. When prompted, type the provided SCU activation password and press Enter.
    1. Confirm that you see a success message.
    1. Type `exit` and press Enter to return to the installer.
1. Press "Reboot Now"
1. At the prompt to "Please remove the installation medium, then press ENTER", follow those instructions.
1. The system will reboot and perform the rest of the setup automatically.
