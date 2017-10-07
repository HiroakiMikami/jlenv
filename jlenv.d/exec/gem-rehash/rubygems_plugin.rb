hook = lambda do |installer|
  begin
    # Ignore gems that aren't installed in locations that jlenv searches for binstubs
    if installer.spec.executables.any? &&
        [Gem.default_bindir, Gem.bindir(Gem.user_dir)].include?(installer.bin_dir)
      `jlenv rehash`
    end
  rescue
    warn "jlenv: error in gem-rehash (#{$!.class.name}: #{$!.message})"
  end
end

if defined?(Bundler::Installer) && Bundler::Installer.respond_to?(:install) && !Bundler::Installer.respond_to?(:install_without_jlenv_rehash)
  Bundler::Installer.class_eval do
    class << self
      alias install_without_jlenv_rehash install
      def install(root, definition, options = {})
        begin
          if Gem.default_path.include?(Bundler.bundle_path.to_s)
            bin_dir = Gem.bindir(Bundler.bundle_path.to_s)
            bins_before = File.exist?(bin_dir) ? Dir.entries(bin_dir).size : 2
          end
        rescue
          warn "jlenv: error in Bundler post-install hook (#{$!.class.name}: #{$!.message})"
        end

        result = install_without_jlenv_rehash(root, definition, options)

        if bin_dir && File.exist?(bin_dir) && Dir.entries(bin_dir).size > bins_before
          `jlenv rehash`
        end
        result
      end
    end
  end
else
  begin
    Gem.post_install(&hook)
    Gem.post_uninstall(&hook)
  rescue
    warn "jlenv: error installing gem-rehash hooks (#{$!.class.name}: #{$!.message})"
  end
end
