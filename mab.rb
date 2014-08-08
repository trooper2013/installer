require "formula"

JAVA_MIN_PATCH = 45
JAVA_MIN_VERSION = "1.7.0_" + JAVA_MIN_PATCH.to_s

def error_no_java
  "ERROR: No Java executable found on PATH\n"
end

def error_no_java_in_java_home(java_home)
"""
ERROR: Cannot find Java executable under JAVA_HOME : #{java_home}/bin/java
"""
end

def error_invalid_java_version (version) 
"""  
ERROR: Incorrect Java version #{version}.
  The Magnet Mobile App builder requires Oracle Java #{JAVA_MIN_VERSION} or above.
"""
end

def error_no_maven
  "ERROR: No Maven executable found on PATH\n"
end

def error_cannot_found_maven_version 
"""  
ERROR: Cannot determine Maven version.
  Verify that you have correctly set your JAVA_HOME or M2_HOME
"""
end

def error_no_maven_on_maven_home(maven_home)
"""
ERROR: Incorrect M2_HOME : cannot find Maven executable at #{maven_home}/bin/mvn
"""
end

def error_invalid_maven_version (version) 
"""  
ERROR: The installed Maven version is #{version}. 
  It is recommended to use Apache Maven 3.1+.
  You can install the latest version of maven with 'brew install maven'.
  It is also recommended you remove the old version from your PATH.
  Finally, if you have set M2_HOME, be sure it points to the right maven installation.
"""
end

def error_no_java_home
"""
ERROR: You have not set a JAVA_HOME environment variable. 
  It must point to a valid java installation home. For instance, run:
  export JAVA_HOME=\"$(/usr/libexec/java_home)\"  
"""
end


def error_maven_home_mismatch(maven_on_maven_home, maven_path)
"""
ERROR: Maven executables mismatch.
  M2_HOME points to #{maven_on_maven_home} which is different from the 
  Maven executable on the PATH: #{maven_path} 
  You can fix it with this command: export PATH=$M2_HOME/bin:$PATH
"""
end

def error_java_home_mismatch(java_on_java_home, java_path)
"""
ERROR: Java executables mismatch.
  JAVA_HOME points to #{java_on_java_home} which is different from the 
  Java executable on the PATH #{java_path} 
  You can fix it with this command: export PATH=$JAVA_HOME/bin:$PATH
"""
end

def error_incorrect_mab(mab_path)
"""
ERROR: mab executables conflicting on PATH.
  It appears that you already have a mab executable on your PATH: #{mab_path} 
  Ensure that /usr/local/bin/mab is in front of PATH to use the installed mab.   
"""
end

def check_java
  
  java = which 'java'
  if not java 
    return error_no_java
  end
  
  version = /[0-9]+\.[0-9]+\.[\.0-9_]+/.match(`#{java} -version 2>&1| grep "java version"`).to_s
  version_numbers = version.split('.')
  if (version_numbers[1].to_i < 7) or (version_numbers[1].to_i == 7 && version_numbers[2].split('_')[1].to_i < JAVA_MIN_PATCH)
    return error_invalid_java_version(version)
  end

  nil
end

def check_java_home
  java_home = ENV['JAVA_HOME']

  if not java_home
    return error_no_java_home
  end 

  begin
    java_on_java_home = Pathname.new("#{java_home}/bin/java").realpath.to_s
  rescue Errno::ENOENT
    return error_no_java_in_java_home(java_home)
  end

  java = which 'java'

  java_path = Pathname.new("#{java}").realpath.to_s
  if java_on_java_home != java_path
    return error_java_home_mismatch(java_on_java_home, java_path)
  end
  
  nil
end

def check_mab
 mab = which 'mab'
 if mab 
   return error_incorrect_mab(mab)
 end
 nil
end

def check_maven
  mvn = which 'mvn'
  if not mvn 
    return error_no_maven
  end 

  version =  /[0-9]+\.[0-9]+[\.0-9]*/.match(`#{mvn} -v | grep "Apache Maven"`).to_s
  if version == ""
    return error_cannot_found_maven_version
  end 

  version_numbers = version.split('.')
  if not (version_numbers[0].to_i >= 3 and version_numbers[1].to_i >=1)
    return error_invalid_maven_version(version)
  end

  maven_home = ENV['M2_HOME']

  if not maven_home 
    return nil
  end

  begin
    maven_on_maven_home = Pathname.new("#{maven_home}/bin/mvn").realpath.to_s
  rescue Errno::ENOENT
    return error_no_maven_on_maven_home(maven_home)
  end
  
  maven_path = Pathname.new("#{mvn}").realpath.to_s
  if maven_path != maven_on_maven_home
    return error_maven_home_mismatch(maven_on_maven_home, maven_path)
  end

  nil
end

class JavaDependency < Requirement
  fatal true

  @error = nil

  def message
    @error
  end

  satisfy :build_env => false do
    @error = (check_java ? check_java : "") + (check_java_home ? check_java_home : "") 
    not (@error != "") 
  end

end

class MavenDependency < Requirement
  fatal true
  default_formula 'maven'

  @error = nil

  def message
    @error
  end

  satisfy do
    not (@error = check_maven)
  end
end

class MySqlDependency < Requirement
  fatal true
  default_formula 'mysql'

  satisfy do
   which 'mysql_config'
  end
end

#
# MAB formula (devel and stable)
#
class Mab < Formula
  homepage 'http://factory.magnet.com'
  url "https://raw.githubusercontent.com/magnetsystems/installer/master/magnet-tools-cli-installer-2.3.0.tgz"
  sha1 '1edb907dbd32fc7b809569cb4ab459b021367171'


  option 'with-mysql', 'MySQL will be installed'
  option 'without-maven' , 'Maven will not be installed'

  depends_on MavenDependency => :recommended
  depends_on MySqlDependency => :optional
  depends_on JavaDependency => :recommended

  
  def install
    prefix.install Dir['*']
  end


  def caveats 
    issues = (check_java ? check_java : "") + (check_java_home ? check_java_home : "") + (check_maven ? check_maven : "") + (check_mab ? check_mab : "")
    if (issues == "") 
      return """NO CAVEATS. INSTALLATION SUCCESSFUL!
  Congratulations! The Mobile App Builder has been installed under /usr/local/bin/mab.
  To uninstall it, run 'brew remove mab'.
"""
    end 
    return issues
  end 


end
