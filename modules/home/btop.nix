{pkgs, useNvidia, ...}: {
  programs.btop = {
    enable = true;
    package = pkgs.btop.override {
      rocmSupport = !useNvidia; # ROCm backend only useful on AMD/other GPUs
      cudaSupport = useNvidia;  # CUDA backend only on NVIDIA
    };
    settings = {
      vim_keys = true;
      rounded_corners = true;
      proc_tree = true;
      show_gpu_info = "on";
      show_uptime = true;
      show_coretemp = true;
      cpu_sensor = "auto";
      show_disks = true;
      only_physical = true;
      io_mode = true;
      io_graph_combined = false;
    };
  };
}
