{ root, ... }: {
  sops.defaultSopsFile = "${root}/secrets/secrets.yaml";
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/var/lib/sops-age/keys.txt";
}
