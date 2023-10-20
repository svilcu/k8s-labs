# About

Install docker-ce and luci interface on OpenWRT

```bash
opkg install docker luci-app-dockerman docker-compose dockerd fuse-overlayfs kmod-nf-conntrack-netlink python3-docker python3-dockerpty --force-maintainer

docker run -d -p 5000:5000 --restart=always --name registry registry:2

```

## Documentation

[Openwrt docker](https://openwrt.org/docs/guide-user/virtualization/docker_host)
[docker-config](https://raw.githubusercontent.com/openwrt/packages/master/utils/dockerd/files/etc/config/dockerd)
[How to install dockerCE](https://forum.openwrt.org/t/getting-docker-to-work-first-try/132252/12)
[How to install Docker registry](https://docs.docker.com/registry/deploying/)
