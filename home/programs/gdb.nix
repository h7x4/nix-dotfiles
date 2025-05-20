{ pkgs, ... }:
{
  xdg.configFile."gdb/gdbinit".text = ''
    # C++ related beautifiers
    set print pretty on
    set print object on
    set print static-members on
    set print vtbl on
    set print demangle on
    set print sevenbit-strings off
    set print asm-demangle on
    set print elements 0

    # Assembly
    set disassembly-flavor intel

    # Save command history between sessions:
    set history save

    # Print a beautifully colored prompt:
    set prompt \001\033[1;36m\002(gdb) \001\033[0m\002
  '';

  # local.shell.aliases."System Tool Replacements".gdb = "${pkgs.pwndbg}/bin/pwndbg";
}
