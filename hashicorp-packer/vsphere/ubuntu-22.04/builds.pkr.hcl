/////////////////////////////////////////////////
// BUILDS
/////////////////////////////////////////////////

build {
  sources = [
    "source.vsphere-iso.UBUNTU",
  ]

  provisioner "shell" {
    inline = [
      "touch /tmp/hello.txt",
      "ls -lh /tmp",
    ]
  } 
}
