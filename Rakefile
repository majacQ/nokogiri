# -*- ruby -*-
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :debugging
Hoe.plugin :gemspec
  <<<<<<< flavorjones-concourse-across-matrix
Hoe.plugin :git
Hoe.plugin :markdown
  =======
Hoe.plugin :bundler

GENERATED_PARSER    = "lib/nokogiri/css/parser.rb"
GENERATED_TOKENIZER = "lib/nokogiri/css/tokenizer.rb"

require 'jars/installer'
desc "Resolve jarfile dependencies"
task :install_jars do
  Jars::Installer.vendor_jars!
end

def java?
  /java/ === RUBY_PLATFORM
end

ENV['LANG'] = "en_US.UTF-8" # UBUNTU 10.04, Y U NO DEFAULT TO UTF-8?

CrossRuby = Struct.new(:version, :host) {
  def ver
    @ver ||= version[/\A[^-]+/]
  end

  def minor_ver
    @minor_ver ||= ver[/\A\d\.\d(?=\.)/]
  end

  def api_ver_suffix
    case minor_ver
    when nil
      raise "unsupported version: #{ver}"
    else
      minor_ver.delete('.') << '0'
    end
  end

  def platform
    @platform ||=
      case host
      when /\Ax86_64-/
        'x64-mingw32'
      when /\Ai[3-6]86-/
        'x86-mingw32'
      else
        raise "unsupported host: #{host}"
      end
  end

  def tool(name)
    (@binutils_prefix ||=
      case platform
      when 'x64-mingw32'
        'x86_64-w64-mingw32-'
      when 'x86-mingw32'
        'i686-w64-mingw32-'
      end) + name
  end

  def target
    case platform
    when 'x64-mingw32'
      'pei-x86-64'
    when 'x86-mingw32'
      'pei-i386'
    end
  end

  def libruby_dll
    case platform
    when 'x64-mingw32'
      "x64-msvcrt-ruby#{api_ver_suffix}.dll"
    when 'x86-mingw32'
      "msvcrt-ruby#{api_ver_suffix}.dll"
    end
  end

  def dlls
    [
      'kernel32.dll',
      'msvcrt.dll',
      'ws2_32.dll',
      *(case
        when ver >= '2.0.0'
          'user32.dll'
        end),
      libruby_dll
    ]
  end
}
  >>>>>>> 1253-use-jar-dependencies

require 'shellwords'

require_relative "tasks/util"
require_relative "tasks/cross-ruby"

HOE = Hoe.spec 'nokogiri' do
  developer 'Aaron Patterson', 'aaronp@rubyforge.org'
  developer 'Mike Dalessio',   'mike.dalessio@gmail.com'
  developer 'Yoko Harada',     'yokolet@gmail.com'
  developer 'Tim Elliott',     'tle@holymonkey.com'
  developer 'Akinori MUSHA',   'knu@idaemons.org'
  developer 'John Shahid',     'jvshahid@gmail.com'
  developer 'Lars Kanis',      'lars@greiz-reinsdorf.de'

  license "MIT"

  self.urls = {
    "home" => "https://nokogiri.org",
    "bugs" => "https://github.com/sparklemotion/nokogiri/issues",
    "doco" => "https://nokogiri.org/rdoc/index.html",
    "clog" => "https://nokogiri.org/CHANGELOG.html",
    "code" => "https://github.com/sparklemotion/nokogiri",
  }

  self.markdown_linkify_files = FileList["*.md"]
  self.extra_rdoc_files = FileList['ext/nokogiri/*.c']

  self.clean_globs += [
    'nokogiri.gemspec',
    'lib/nokogiri/nokogiri.{bundle,jar,rb,so}',
    'lib/nokogiri/[0-9].[0-9]',
  ]
  self.clean_globs += Dir.glob("ports/*").reject { |d| d =~ %r{/archives$} }

  unless java?
    self.extra_deps += [
      ["mini_portile2", "~> 2.5.0"], # keep version in sync with extconf.rb
    ]
  end

  self.extra_dev_deps += [
    ["concourse", "~> 0.34"],
    ["hoe", ["~> 3.22", ">= 3.22.1"]],
    ["hoe-bundler", "~> 1.2"],
    ["hoe-debugging", "~> 2.0"],
    ["hoe-gemspec", "~> 1.0"],
    ["hoe-git", "~> 1.6"],
    ["hoe-markdown", "~> 1.1"],
    ["minitest", "~> 5.8"],
    ["racc", "~> 1.4.14"],
    ["rake", "~> 13.0"],
    ["rake-compiler", "~> 1.1"],
    ["rake-compiler-dock", "~> 1.0"],
    ["rexical", "~> 1.0.5"],
    ["rubocop", "~> 0.88"],
    ["simplecov", "~> 0.17.0"], # locked due to https://github.com/codeclimate/test-reporter/issues/413
  ]

  if java?
    self.extra_dev_deps += [
      ["jar-dependencies",   "~> 0.4"],
      ["jbundler",           "~> 0.9"],
    ]
  end

  self.spec_extras = {
    :extensions => ["ext/nokogiri/extconf.rb"],
    :required_ruby_version => '>= 2.4.0'
  }

  self.testlib = :minitest
  self.test_prelude = 'require "helper"' # ensure simplecov gets loaded before anything else
end

if java?
  # TODO: clean this section up.
  require "rake/javaextensiontask"
  Rake::JavaExtensionTask.new("nokogiri", HOE.spec) do |ext|
    jruby_home = RbConfig::CONFIG['prefix']
    ext.ext_dir = 'ext/java'
    ext.lib_dir = 'lib/nokogiri'
    ext.source_version = '1.6'
    ext.target_version = '1.6'
    jars = ["#{jruby_home}/lib/jruby.jar"] + FileList['lib/*.jar']
    ext.classpath = jars.map { |x| File.expand_path x }.join ':'
    ext.debug = true if ENV['JAVA_DEBUG']
  end

  task gem_build_path => [:compile] do
    add_file_to_gem 'lib/nokogiri/nokogiri.jar'
  end
else
  require "rake/extensiontask"

  HOE.spec.files.reject! { |f| f =~ %r{\.(java|jar)$} }

  dependencies = YAML.load_file("dependencies.yml")

  task gem_build_path do
    %w[libxml2 libxslt].each do |lib|
      version = dependencies[lib]["version"]
      archive = File.join("ports", "archives", "#{lib}-#{version}.tar.gz")
      add_file_to_gem archive
      patchesdir = File.join("patches", lib)
      patches = `#{['git', 'ls-files', patchesdir].shelljoin}`.split("\n").grep(/\.patch\z/)
      patches.each { |patch|
        add_file_to_gem patch
      }
      (untracked = Dir[File.join(patchesdir, '*.patch')] - patches).empty? or
        at_exit {
          untracked.each { |patch|
            puts "** WARNING: untracked patch file not added to gem: #{patch}"
          }
        }
    end
  end

  Rake::ExtensionTask.new("nokogiri", HOE.spec) do |ext|
    ext.lib_dir = File.join(*['lib', 'nokogiri', ENV['FAT_DIR']].compact)
    ext.config_options << ENV['EXTOPTS']
    ext.cross_compile  = true
    ext.cross_platform = CROSS_RUBIES.map(&:platform).uniq
    ext.cross_config_options << "--enable-cross-build"
    ext.cross_compiling do |spec|
      libs = dependencies.map { |name, dep| "#{name}-#{dep["version"]}" }.join(', ')

      spec.post_install_message = <<-EOS
Nokogiri is built with the packaged libraries: #{libs}.
      EOS
      spec.files.reject! { |path| File.fnmatch?('ports/*', path) }
      spec.dependencies.reject! { |dep| dep.name=='mini_portile2' }
    end
  end
end

require_relative "tasks/concourse"
require_relative "tasks/css-generate"
require_relative "tasks/debug"
require_relative "tasks/docker"
require_relative "tasks/docs-linkify"
require_relative "tasks/rubocop"
require_relative "tasks/set-version-to-timestamp"

# vim: syntax=Ruby
