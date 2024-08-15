{ pkgs, ... }:

# This is the command that will be run by ssh via the ForceCommand option
# (see https://man.openbsd.org/sshd_config#ForceCommand)
# TODO: change it to whatever you want
let sshCommand = pkgs.writeShellScriptBin "bf" ''
  exec ${pkgs.haskellPackages.brainfuck-tut}/bin/bfh 500 "$SSH_ORIGINAL_COMMAND"
'';
in
{

  garnix.server = {
    # This sets up networking and filesystems in a way that works with garnix
    # hosting
    enable = true;
    # These options make garnix redeploy to the same server rather than
    # spinning up a new one. We do that here so the IP address is stable, since
    # the `garnix.me` domains don't work with SSH.
    persistence = {
      enable = true;
      name = "myapp";
    };
  };

  # This enables SSH, but, for user "me", only allows using the sshCommand
  # above.
  services.openssh = {
    enable = true;
    extraConfig = ''
      Match user me
        ForceCommand ${sshCommand}/bin/bf
    '';
  };
  # We create a user called "me". We want everyone to be able to login, so we
  # set a simple password
  users.users.me = {
    # This lets NixOS know this is a "real" user rather than a system user,
    # giving you for example a home directory.
    isNormalUser = true;
    description = "me";
    password = "hi";
  };

  # This is currently the only allowed value.
  nixpkgs.hostPlatform = "x86_64-linux";
}
