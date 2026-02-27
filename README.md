# Yocto Base Configuration for QEMU ARM64

This configuration defines a customized **Yocto Project** environment
optimized for building and running embedded Linux images targeting
the **QEMU ARM64 (aarch64)** virtual platform.

It uses the **Poky** reference distribution with **systemd** as the init manager,
and includes package management, AI/ML libraries, and essential development tools
for rapid emulation and testing.

---

### Key Highlights:

* **Target Machine:** qemuarm64 (64-bit)
* **Distro:** poky (systemd)
* **Build Optimizations:** parallel make (6 threads)
* **Package Management:** APT, dpkg enabled
* **Network & Utilities:** SSH (Dropbear + OpenSSH), NFS server/client, net-tools, iproute2
* **System Monitoring Tools:** htop, iotop, iftop, sysstat, procps
* **AI & Vision Support:** OpenCV, TensorFlow Lite (2.9.3), ONNX Runtime,
  Arm Compute Library, OpenCL ICD loader
* **Python Environment:** Python 3.13 with NumPy and Pillow bindings
* **Graphics:** Mesa as the preferred libGL provider
* **Default User:** `devuser` / `dev123` for development access

---

This setup is designed for developers working on **AI, computer vision, and embedded Linux prototyping** using **QEMU ARM64**, providing a ready-to-run environment with preinstalled frameworks and debugging tools.
