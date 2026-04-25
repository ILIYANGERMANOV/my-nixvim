{ ... }: {
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-age/keys.txt";
}
