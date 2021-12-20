resource "null_resource" "script" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = "127.0.0.1"
      user        = var.username
      private_key = var.ssh_key
      timeout     = "30s"
    }
    inline = [
      join("",["sudo mkdir /tmp/",var.container_name," 2> /dev/null;"]),
      join("",["sudo echo \\<Html\\>\\<title\\>Sample Nginx Web Page\\</title\\>\\<b\\>Hello World\\</b\\>\\<\\i\\>\\Hello World\\</i\\>\\<u\\> Hello World\\</u\\>\\</Html\\> | sudo tee /tmp/",var.container_name,"/index.html 1> /dev/null;"]),
      join("",["sudo chown -R 1000:1000 /tmp/",var.container_name,"; exit 0"])
    ]
  }
}