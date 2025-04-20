# Shield fork for OpenWRT

The current state of this repository assumes the following:

The following should be peer directories:

- `openwrt`: Clone this branch: `https://github.com/CriticalShift/openwrt/tree/shield-0.3-checkpoint`
- `linux-compulab`: Clone this branch: `https://github.com/CriticalShift/linux-compulab` (the default `linux-compulab_v5.15.71` branch)
- (Optional, I think?) `u-boot-compulab`: From here: `https://github.com/CriticalShift/u-boot-compulab` (I think the package under `packages/boot` simply pulls directly from their repository.)

You may need additional tooling that is listed in the READMEs of the `linux-compulab` repository and the `u-boot-compulab` repositories above and beyond what is required for OpenWRT. I will list those packages as I re-discover them.

## Terminology around hardware / target

You will see references to `Compulab`, `ucm-imx8m-plus`, and `shield`. `Compulab` is the vendor of our SoM, the `ucm-imx8m-plus`. We used their code as a starting point - hence you will still see references to `ucm-imx8m-plus`. It is based on the `imx8mp` System on a Chip. `Shield` is the product name that we are building. So in the diffs, some things may still be named `ucm-imx8m-plus` and some newer things will be named `Shield`. In the context of this repository, they are likely referring to the same thing.

## Configs

Both the defconfig and diffconfig version of OpenWRT's `.config` file has been captured in `targets/linux/imx/diffconfigs` folder. They've started to be broken down in the `modules` subdirectory.

Some kernel modules and low level libraries / services have been added directly to the `imx8.mk` file in the `imx/image` folder.

## Custom kernel

The most important commits in the custom kernel tree are:

- (Cell modem patch) https://github.com/compulab-yokneam/linux-compulab/commit/cf8c94b720eccaf3ca26766efaf4ba54259b9fc6
- (Fix in imx_sim.c) https://github.com/compulab-yokneam/linux-compulab/commit/d0f44c82c350c1b41583a8d8e211c7f54356f5c9
- (Patch EQoS MAC driver to allow VLAN in promisc mode) https://github.com/compulab-yokneam/linux-compulab/commit/d08a2a8bd77735480dc0e83df3cb69159d7e47a2
- The contents of `arch/arm64/boot/dts/kform` which contains the custom device trees.