require "formula"

JAVA_MIN_PATCH = 45
JAVA_MIN_VERSION = "1.7.0_" + JAVA_MIN_PATCH.to_s

def error_no_java
  "ERROR: No Java executable found on PATH\n"
end

def error_invalid_java_version (version) 
"""  
ERROR: Incorrect Java version #{version}.
  The Magnet Mobile App builder requires Oracle Java #{JAVA_MIN_VERSION} or above.
"""
end

def error_incorrect_mab(mab_path)
"""
ERROR: mob executables conflicting on PATH.
  It appears that you already have a mob executable on your PATH: #{mab_path} 
  Ensure that /usr/local/bin/mob is in front of PATH to use the installed mab.   
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

def check_mab
 mob = which 'mob'
 if mob 
   return error_incorrect_mab(mob)
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

#
# MOB formula (devel and stable)
#
class Mab < Formula
  homepage 'http://factory.magnet.com'
  url "https://raw.githubusercontent.com/magnetsystems/installer/master/magnet-tools-cli-mob-installer-2.3.0-SNAPSHOT.tgz"
  sha1 '5d5ed452b0f3243f4981bc1ea25a6d0c7d60202c'


  option 'with-mysql', 'MySQL will be installed'
  option 'without-maven' , 'Maven will not be installed'

  depends_on MavenDependency => :recommended
  depends_on MySqlDependency => :optional
  depends_on JavaDependency => :recommended

  
  def install
    prefix.install Dir['*']
  end


  def caveats 
    issues = (check_java ? check_java : "") + (check_mab ? check_mab : "")
    if (issues == "") 
      return """NO CAVEATS. INSTALLATION SUCCESSFUL!
  Congratulations! The Mobile Generator has been installed under /usr/local/bin/mob.
  To uninstall it, run 'brew remove mob'.
"""
    end 
    return issues
  end 


end
