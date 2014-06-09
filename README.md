Magnet App Builder Installer
===================================

Version
-------
 - Stable: 2.3.0_M7.1

Requirements
------------
  - JDK 1.7.0_51 or above
  - Maven 3.1.1 or above

Optional
--------
  - MySql 5.5 or above 


The installer automatically installs Maven if it does not find it on the PATH. You must install Java Development Kit 1.7 (update 51 or above) yourself and correctly export your JAVA_HOME environment variable. 
You can add thes lines to your .profile, or .bashrc. 

```
# if /usr/libexec/java_home does not point to the latest installation of Java, then set it manually. 
# For instance, if you installed the JDK1.7.0_51, it would typically be:
#export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.7.0_51.jdk/Contents/Home
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH=$JAVA_HOME/bin:$PATH
```

You can customize the installation of the sofware dependencies with:
 - use _--with-mysql_ to install MySql 
 - use _--without-maven_ to skip Maven installation


MacOS
-----
Run:
```
brew install https://raw.githubusercontent.com/etexier/installer/master/mab.rb
```

If you don't have _brew_, go to: http://brew.sh/

Verify your installation by running:
```
brew info mab
```
This will identify all potential caveats on your system. 

To use MySql instead of the built-in H2 database, be sure it is running. If you installed it with brew, check its status with:

```
mysql.server status
```
and start it with:
```
mysql.server start
```

To install future versions of mab, but keep the old version
```
brew unlink mab
brew install https://raw.githubusercontent.com/etexier/installer/master/mab.rb
```

You can switch version the following way (assuming you installed a previous version):
```
brew switch mab <version>
```

To uninstall mab:
```
brew remove mab
```
Linux
-----
TBD

Windows
-------
TBD
