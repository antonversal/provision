package :rbenv do
  description 'Install rbenv Ruby version manager'

  requires :install_rbenv, :install_ruby_build, :install_ruby, :add_rbenv_bundler
end

package :install_rbenv do
  description 'Install rbenv Ruby version manager'

  requires :git

  runner "true; git clone git://github.com/sstephenson/rbenv.git ~/.rbenv"
  push_text 'export PATH="$HOME/.rbenv/bin:$PATH"', "~/.bash_profile"
  push_text 'eval "$(rbenv init -)"', "~/.bash_profile"
  #runner "chown #{user} #{home_path}/.bash_profile"
  #runner "chmod -R g+rwxXs ~/.rbenv"

  verify do
    has_executable "~/.rbenv/bin/rbenv"
  end
end

package :install_ruby_build do
  description 'Install lib to build rubies'

  requires :git

  runner "rm -rf ~/.rbenv/plugins/ruby-build"
  runner "true; git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build"

  verify do
    @commands << "~/.rbenv/bin/rbenv install|grep Usage"
  end
end

package :ruby_dependencies do
  description 'Setup Ruby dependencies'
  apt 'libssl-dev zlib1g-dev libreadline-dev libpq-dev libyaml-dev build-essential flex gettext' do
    pre :install, ['aptitude update']
  end

  verify do
    has_apt 'libssl-dev'
    has_apt 'zlib1g-dev'
    has_apt 'libreadline-dev'
    has_apt 'libpq-dev'
    has_apt 'libyaml-dev'
    has_apt 'build-essential'
    has_apt 'flex'
    has_apt 'gettext'
  end
end

package :install_ruby do
  description 'Install Ruby'
  version '2.1.0'
  requires :install_ruby_build, :ruby_dependencies

  runner "true; CONFIGURE_OPTS=\"--disable-install-doc\" ~/.rbenv/bin/rbenv install -f -v #{version}", sudo: false
  runner 'true; touch ~/.rbenv/global'
  push_text version, '~/.rbenv/global'
  runner 'true; echo "gem: --no-ri --no-rdoc\n" > ~/.gemrc'

  verify do
    @commands << "~/.rbenv/bin/rbenv versions | grep #{version}"
    file_contains '~/.rbenv/global', version
  end
end

package :add_rbenv_bundler do
  version '2.1.0'
  runner "true; ~/.rbenv/versions/#{version}/bin/gem install bundler --no-ri --no-rdoc"
  runner "true; ~/.rbenv/bin/rbenv rehash"

  verify do
    @commands << "~/.rbenv/versions/#{version}/bin/gem list | grep bundler"
  end
end
