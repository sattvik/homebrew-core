class Maven < Formula
  desc "Java-based project management"
  homepage "https://maven.apache.org/"

  stable do
    url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
    mirror "https://archive.apache.org/dist/maven/maven-3/3.3.9/binaries/apache-maven-3.3.9-bin.tar.gz"
    sha256 "6e3e9c949ab4695a204f74038717aa7b2689b1be94875899ac1b3fe42800ff82"
  end

  devel do
    url "https://www.apache.org/dyn/closer.cgi?path=maven/maven-3/3.5.0-alpha-1/binaries/apache-maven-3.5.0-alpha-1-bin.tar.gz"
    mirror "https://archive.apache.org/dist/maven/maven-3/3.5.0-alpha-1/binaries/apache-maven-3.5.0-alpha-1-bin.tar.gz"
    sha256 "7421b3737729ea4e3865c33af6fbf4e50f9820b477d46eaff9492ad940785cd7"
    version "3.5.0-alpha-1"
  end

  bottle :unneeded

  depends_on :java => "1.7+"

  conflicts_with "mvnvm", :because => "also installs a 'mvn' executable"

  def install
    # Remove windows files
    rm_f Dir["bin/*.bat"]

    # Fix the permissions on the global settings file.
    chmod 0644, "conf/settings.xml"

    libexec.install Dir["*"]

    # Leave conf file in libexec. The mvn symlink will be resolved and the conf
    # file will be found relative to it
    Pathname.glob("#{libexec}/bin/*") do |file|
      next if file.directory?
      basename = file.basename
      next if basename.to_s == "m2.conf"
      (bin/basename).write_env_script file, Language::Java.overridable_java_home_env
    end
  end

  test do
    (testpath/"pom.xml").write <<-EOS.undent
      <?xml version="1.0" encoding="UTF-8"?>
      <project xmlns="https://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="https://maven.apache.org/POM/4.0.0 http://maven.apache.org/maven-v4_0_0.xsd">
        <modelVersion>4.0.0</modelVersion>
        <groupId>org.homebrew</groupId>
        <artifactId>maven-test</artifactId>
        <version>1.0.0-SNAPSHOT</version>
      </project>
    EOS
    (testpath/"src/main/java/org/homebrew/MavenTest.java").write <<-EOS.undent
      package org.homebrew;
      public class MavenTest {
        public static void main(String[] args) {
          System.out.println("Testing Maven with Homebrew!");
        }
      }
    EOS
    system "#{bin}/mvn", "compile", "-Duser.home=#{testpath}"
  end
end
