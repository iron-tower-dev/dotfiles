# NixOS Modules
# This file imports all custom NixOS modules
{
  imports = [
    ./desktop
    ./programs
    ./services
    ./themes
  ];
}
